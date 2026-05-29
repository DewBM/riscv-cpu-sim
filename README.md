# RV32I Pipeline Simulator

A cycle-accurate RV32I instruction set simulator implementing a classic 5-stage pipeline (IF, ID, EX, MEM, WB) written in C.


## Implemented Instructions

| Group   | Instructions                     |
|---------|----------------------------------|
| OP      | ADD, SUB, AND, OR, SLL, SRL, SRA, SLT, SLTU |
| OP-IMM  | ADDI, ANDI, ORI, XORI, SLTI, SLTIU, SLLI, SRLI, SRAI |
| LOAD    | LW, LH, LB, LBU, LHU             |
| STORE   | SW, SH, SB                       |
| BRANCH  | BEQ, BNE, BLT, BGE, BLTU, BGEU   |
| JUMP    | JAL, JALR                        |
| UPPER IMM | LUI, AUIPC |
## Requirements

- `gcc`
- `riscv32-unknown-elf-as`, `riscv32-unknown-elf-ld`, `riscv32-unknown-elf-objcopy`
- `qemu-riscv32`
- `gdb` (multiarch support)
- `python3`

## Build

```bash
make
```

Simulator binary is output to `build/simulator`.

## Usage

```bash
./build/simulator <program.bin>
```

## Testing

Tests compare simulator register state against QEMU as ground truth via GDB RSP.

```bash
make test
```

To debug a specific test:

```bash
# Debug simulator C code
python3 tests/run_tests.py --debug-sim <test_name>

# Debug RISC-V assembly in QEMU
python3 tests/run_tests.py --debug-qemu <test_name>
```

Available tests: `test_op`, `test_op_imm`, `test_load_store`, `test_branch`, `test_jal_jalr`
