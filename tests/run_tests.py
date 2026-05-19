#!/usr/bin/env python3
"""
RV32I Simulator Test Runner
Compares simulator register output against QEMU (ground truth) via GDB RSP.
"""

import os
import sys
import socket
import subprocess
import time
import signal
from dataclasses import dataclass
from typing import Optional

# ── Configuration ─────────────────────────────────────────────────────────────

SIMULATOR  = os.path.join(os.path.dirname(__file__), "../build/simulator")
TESTS_DIR  = os.path.dirname(__file__)
BINS_DIR   = os.path.join(TESTS_DIR, "bins")
ELFS_DIR   = os.path.join(TESTS_DIR, "elfs")
GDB_PORT   = 12345
SIM_TIMEOUT  = 3    # seconds before simulator is declared hung
QEMU_TIMEOUT = 5    # seconds before QEMU GDB session is declared hung

TESTS = [
    "test_op",
    "test_op_imm",
    "test_load_store",
    "test_branch",
    "test_jal_jalr",
]

# ── GDB Remote Serial Protocol client ─────────────────────────────────────────

class GDBClient:
    def __init__(self, port: int, timeout: float = QEMU_TIMEOUT):
        self.sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.sock.settimeout(timeout)
        self.sock.connect(("localhost", port))

    def close(self):
        try:
            self.sock.close()
        except Exception:
            pass

    def _checksum(self, data: str) -> int:
        return sum(ord(c) for c in data) % 256

    def _send(self, cmd: str):
        cs = self._checksum(cmd)
        packet = f"${cmd}#{cs:02x}"
        self.sock.sendall(packet.encode("latin-1"))
        ack = self.sock.recv(1)
        if ack != b"+":
            raise RuntimeError(f"GDB: no ack for '{cmd}', got {ack!r}")

    def _recv(self) -> str:
        buf = ""
        in_packet = False
        while True:
            c = self.sock.recv(1).decode("latin-1")
            if c == "$":
                buf = ""
                in_packet = True
            elif c == "#" and in_packet:
                self.sock.recv(2)           # consume 2-char checksum
                self.sock.sendall(b"+")     # ack
                return buf
            elif in_packet:
                buf += c

    def query_status(self) -> str:
        self._send("?")
        return self._recv()

    def cont(self) -> str:
        """Continue execution; returns stop-reply packet (e.g. 'S05')."""
        self._send("c")
        return self._recv()

    def read_registers(self) -> list[int]:
        """Read x0–x31 from GDB 'g' packet (little-endian rv32i)."""
        self._send("g")
        hex_str = self._recv()
        regs = []
        for i in range(32):
            chunk = hex_str[i * 8 : (i + 1) * 8]
            if len(chunk) < 8:
                regs.append(0)
            else:
                val = int.from_bytes(bytes.fromhex(chunk), "little")
                regs.append(val)
        return regs

    def kill(self):
        try:
            self._send("k")
        except Exception:
            pass


# ── QEMU helpers ──────────────────────────────────────────────────────────────

def connect_gdb(port: int, retries: int = 40, delay: float = 0.1) -> Optional["GDBClient"]:
    """Retry connecting GDBClient directly — avoids probe-then-connect race."""
    for _ in range(retries):
        try:
            return GDBClient(port)
        except (ConnectionRefusedError, socket.timeout, OSError):
            time.sleep(delay)
    return None


def get_qemu_registers(elf_path: str, port: int = GDB_PORT) -> Optional[list[int]]:
    """Run elf under QEMU with GDB stub; return register list after EBREAK."""
    proc = subprocess.Popen(
        ["qemu-riscv32", "-g", str(port), elf_path],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )
    try:
        # Connect directly — do NOT probe the port first (a probe connect +
        # disconnect causes QEMU's GDB stub to close, giving "Connection reset")
        client = connect_gdb(port)
        if client is None:
            proc.kill()
            return None

        try:
            client.query_status()      # acknowledge initial stopped state
            stop = client.cont()       # run until EBREAK → SIGTRAP (S05/T05)
            # S05 or T05... = SIGTRAP from EBREAK
            # Anything else (e.g. S0b = SIGSEGV) means program crashed in QEMU
            if not any(sig in stop for sig in ("S05", "T05")):
                print(f"      QEMU stopped with unexpected signal: {stop[:8]!r}")
                return None
            regs = client.read_registers()
            client.kill()
            return regs
        except Exception as e:
            print(f"      GDB error: {e}")
            return None
        finally:
            client.close()
    finally:
        proc.wait(timeout=3)


# ── Simulator helpers ─────────────────────────────────────────────────────────

def get_simulator_registers(bin_path: str) -> Optional[list[int]]:
    """Run simulator; parse reg_dump output into a register list."""
    try:
        result = subprocess.run(
            [SIMULATOR, bin_path],
            capture_output=True,
            text=True,
            timeout=SIM_TIMEOUT,
        )
    except subprocess.TimeoutExpired:
        return None     # caller treats None as TIMEOUT

    regs = [None] * 32
    for line in result.stdout.splitlines():
        # Expected format: "x0: 0x00000000"
        line = line.strip()
        if not line or ":" not in line:
            continue
        name, _, val = line.partition(":")
        name = name.strip()
        val  = val.strip()
        if name.startswith("x") and name[1:].isdigit():
            idx = int(name[1:])
            if 0 <= idx < 32:
                try:
                    regs[idx] = int(val, 16)
                except ValueError:
                    pass
    return regs if any(r is not None for r in regs) else None


# ── Result types ──────────────────────────────────────────────────────────────

@dataclass
class Mismatch:
    reg:      int
    expected: int
    actual:   Optional[int]

@dataclass
class TestResult:
    name:       str
    passed:     bool
    timeout:    bool
    qemu_fail:  bool
    mismatches: list[Mismatch]


# ── Core comparison ───────────────────────────────────────────────────────────

def compare(name: str, qemu_regs: list[int], sim_regs: list[int]) -> TestResult:
    mismatches = []
    for i in range(32):
        exp = qemu_regs[i]
        act = sim_regs[i] if sim_regs[i] is not None else None
        if act != exp:
            mismatches.append(Mismatch(i, exp, act))
    return TestResult(
        name=name,
        passed=len(mismatches) == 0,
        timeout=False,
        qemu_fail=False,
        mismatches=mismatches,
    )


# ── Report formatting ─────────────────────────────────────────────────────────

def print_separator(char="─", width=60):
    print(char * width)

def print_result(r: TestResult):
    if r.qemu_fail:
        status = "⚠  QEMU FAIL"
    elif r.timeout:
        status = "⏱  TIMEOUT  "
    elif r.passed:
        status = "✓  PASS     "
    else:
        status = "✗  FAIL     "

    print(f"  {status}  {r.name}")

    if r.timeout:
        print(f"            Simulator did not terminate within {SIM_TIMEOUT}s.")
        print( "            Likely caused by a buggy jump landing on wrong code.")
    elif r.qemu_fail:
        print( "            QEMU could not produce reference output.")
    elif not r.passed:
        print(f"            {len(r.mismatches)} register(s) differ:")
        for m in r.mismatches:
            act_str = f"0x{m.actual:08x}" if m.actual is not None else "  <missing>"
            print(f"            x{m.reg:<2}  expected 0x{m.expected:08x}  got {act_str}")


def print_summary(results: list[TestResult]):
    passed  = sum(1 for r in results if r.passed)
    failed  = sum(1 for r in results if not r.passed and not r.timeout and not r.qemu_fail)
    timeouts = sum(1 for r in results if r.timeout)
    qfails  = sum(1 for r in results if r.qemu_fail)
    total   = len(results)

    print()
    print_separator("═")
    print(f"  Results: {passed}/{total} passed", end="")
    if failed:    print(f"  │  {failed} failed", end="")
    if timeouts:  print(f"  │  {timeouts} timeout", end="")
    if qfails:    print(f"  │  {qfails} qemu-error", end="")
    print()
    print_separator("═")


# ── Main ──────────────────────────────────────────────────────────────────────

def run_all_tests() -> list[TestResult]:
    results = []

    print()
    print_separator("═")
    print("  RV32I Simulator Test Suite")
    print_separator("═")
    print()

    for name in TESTS:
        elf_path = os.path.join(ELFS_DIR, f"{name}.elf")
        bin_path = os.path.join(BINS_DIR, f"{name}.bin")

        # Check files exist
        for path, label in [(elf_path, "ELF"), (bin_path, "BIN")]:
            if not os.path.exists(path):
                print(f"  SKIP  {name}  ({label} not found — run 'make' first)")
                continue

        # Ground truth from QEMU
        qemu_regs = get_qemu_registers(elf_path)
        if qemu_regs is None:
            r = TestResult(name=name, passed=False, timeout=False,
                           qemu_fail=True, mismatches=[])
            results.append(r)
            print_result(r)
            continue

        # Simulator output
        sim_regs = get_simulator_registers(bin_path)
        if sim_regs is None:
            r = TestResult(name=name, passed=False, timeout=True,
                           qemu_fail=False, mismatches=[])
            results.append(r)
            print_result(r)
            continue

        # Compare
        r = compare(name, qemu_regs, sim_regs)
        results.append(r)
        print_result(r)

    print_summary(results)
    return results


def debug_sim(test_name: str):
    """Launch GDB with the simulator running the given test binary."""
    bin_path = os.path.join(BINS_DIR, f"{test_name}.bin")
    if not os.path.exists(bin_path):
        print(f"Error: {bin_path} not found — run 'make build-tests' first.")
        sys.exit(1)
    if not os.path.exists(SIMULATOR):
        print(f"Error: simulator not found at '{SIMULATOR}' — run 'make' first.")
        sys.exit(1)
    print(f"Launching GDB on simulator with {test_name}.bin ...")
    print(f"  Tip: 'break stage_ex' → 'run' → 'print cpu->id_ex' → 'next'")
    print()
    os.execvp("gdb", ["gdb", "--args", SIMULATOR, bin_path])


def debug_qemu(test_name: str, port: int = GDB_PORT):
    """Start QEMU for the given ELF and launch gdb-multiarch to connect."""
    elf_path = os.path.join(ELFS_DIR, f"{test_name}.elf")
    if not os.path.exists(elf_path):
        print(f"Error: {elf_path} not found — run 'make build-tests' first.")
        sys.exit(1)

    print(f"Starting QEMU for {test_name}.elf on port {port} ...")
    proc = subprocess.Popen(
        ["qemu-riscv32", "-g", str(port), elf_path],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )
    print(f"  QEMU pid {proc.pid} — paused at entry point, waiting for GDB.")
    print(f"  Tip: 'stepi' → 'info registers' → 'x/4i $pc' → 'continue'")
    print()

    # Find an available RISC-V capable GDB
    gdb_candidates = [
        "gdb",                        # Arch gdb is multiarch by default
        "gdb-multiarch",              # Ubuntu/Debian
        "riscv32-unknown-elf-gdb",
        "riscv64-unknown-elf-gdb",
    ]
    gdb_bin = None
    for candidate in gdb_candidates:
        result = subprocess.run(
            [candidate, "--version"],
            capture_output=True
        )
        if result.returncode == 0:
            gdb_bin = candidate
            break

    if gdb_bin is None:
        proc.kill()
        print("Error: no suitable GDB found. Install one of:")
        for c in gdb_candidates:
            print(f"  {c}")
        sys.exit(1)

    print(f"  Using: {gdb_bin}")
    os.execvp(gdb_bin, [
        gdb_bin, "-q", elf_path,
        "-ex", "set arch riscv:rv32",
        "-ex", f"target remote :{port}",
    ])


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(description="RV32I simulator test runner")
    parser.add_argument("--debug-sim",  metavar="TEST",
                        help="Launch GDB on the simulator for TEST (debug C code)")
    parser.add_argument("--debug-qemu", metavar="TEST",
                        help="Launch QEMU + gdb-multiarch for TEST (debug RISC-V assembly)")
    args = parser.parse_args()

    if args.debug_sim:
        debug_sim(args.debug_sim)       # does not return (exec)

    if args.debug_qemu:
        debug_qemu(args.debug_qemu)     # does not return (exec)

    # Normal test run
    if not os.path.exists(SIMULATOR):
        print(f"Error: simulator not found at '{SIMULATOR}'")
        print(f"  Build it first, or edit the SIMULATOR path at the top of this script.")
        sys.exit(1)

    results = run_all_tests()
    all_ok = all(r.passed for r in results)
    sys.exit(0 if all_ok else 1)
