# test_comprehensive.s — Comprehensive RV32I instruction test
#
# Tests all implemented instructions, edge cases, combinations,
# and real-world scenarios.
#
# Sections:
#   1.  OP-IMM basic
#   2.  OP basic
#   3.  Shift instructions
#   4.  Set-less-than
#   5.  LUI / AUIPC
#   6.  LOAD / STORE
#   7.  BRANCH
#   8.  JAL / JALR
#   9.  Combinations and real-world scenarios
#
# Register conventions:
#   x1  (ra)  — return address for JAL/JALR tests
#   x2  (sp)  — stack pointer (points to data area)
#   x3-x26    — result registers
#   x27-x31   — scratch/operand registers

.section .text
.global _start

_start:
    # Jump over data area; x2 = address of data_area
    jal  x2, test_start

data_area:
    .word 0    # slot 0:  offset  0
    .word 0    # slot 1:  offset  4
    .word 0    # slot 2:  offset  8
    .word 0    # slot 3:  offset 12
    .word 0    # slot 4:  offset 16
    .word 0    # slot 5:  offset 20
    .word 0    # slot 6:  offset 24
    .word 0    # slot 7:  offset 28

test_start:

# ─────────────────────────────────────────────────────────────────
# SECTION 1: OP-IMM
# ─────────────────────────────────────────────────────────────────

    # ADDI basic
    addi x3,  x0,  100      # x3  = 100
    addi x4,  x0,  -100     # x4  = -100 = 0xFFFFFF9C
    addi x5,  x0,  2047     # x5  = 2047 (max positive 12-bit imm)
    addi x6,  x0,  -2048    # x6  = -2048 (min negative 12-bit imm)
    addi x7,  x0,  0        # x7  = 0 (ADDI with zero imm)
    addi x8,  x3,  50       # x8  = 150 (chain: uses result of previous ADDI)
    addi x9,  x4,  -50      # x9  = -150 = 0xFFFFFF6A

    # ANDI
    addi x27, x0,  -1       # x27 = 0xFFFFFFFF
    andi x10, x27, 0xFF     # x10 = 0x000000FF
    andi x11, x27, 0        # x11 = 0 (AND with 0 = 0)
    andi x12, x3,  0xFF     # x12 = 100 & 0xFF = 100

    # ORI
    ori  x13, x0,  0xFF     # x13 = 0x000000FF
    ori  x14, x27, 0        # x14 = 0xFFFFFFFF (OR with 0 = unchanged)

    # XORI
    xori x15, x27, -1       # x15 = 0 (XOR with all 1s = NOT = 0 since x27=0xFFFFFFFF)
    xori x16, x0,  -1       # x16 = 0xFFFFFFFF (XOR 0 with all 1s)
    xori x17, x3,  0        # x17 = 100 (XOR with 0 = unchanged)

    # SLTI
    addi x27, x0,  -1       # x27 = 0xFFFFFFFF = -1 signed
    slti x18, x27, 0        # x18 = 1 (-1 <s 0)
    slti x19, x3,  100      # x19 = 0 (100 <s 100 = false, equal)
    slti x20, x3,  101      # x20 = 1 (100 <s 101)
    slti x21, x27, -2       # x21 = 0 (-1 <s -2 = false)

    # SLTIU
    sltiu x22, x0,  1       # x22 = 1 (0 <u 1)
    sltiu x23, x27, 1       # x23 = 0 (0xFFFFFFFF <u 1 = false)
    sltiu x24, x3,  101     # x24 = 1 (100 <u 101)

    # SLLI
    addi x27, x0,  1
    slli x25, x27, 0        # x25 = 1 (shift by 0 = unchanged)
    slli x26, x27, 31       # x26 = 0x80000000 (shift into sign bit)

    # SRLI
    addi x27, x0,  -1       # x27 = 0xFFFFFFFF
    srli x3,  x27, 1        # x3  = 0x7FFFFFFF (logical, MSB becomes 0)
    srli x4,  x27, 31       # x4  = 0x00000001
    srli x5,  x27, 0        # x5  = 0xFFFFFFFF (shift by 0 = unchanged)

    # SRAI
    srai x6,  x27, 1        # x6  = 0xFFFFFFFF (arithmetic, MSB stays 1)
    srai x7,  x27, 31       # x7  = 0xFFFFFFFF (all sign bits)
    addi x28, x0,  16
    srai x8,  x28, 2        # x8  = 4 (positive value, same as SRLI)

# ─────────────────────────────────────────────────────────────────
# SECTION 2: OP (R-type)
# ─────────────────────────────────────────────────────────────────

    addi x27, x0,  20
    addi x28, x0,  7
    addi x29, x0,  -1       # x29 = 0xFFFFFFFF

    # ADD
    add  x9,  x27, x28      # x9  = 27
    add  x10, x29, x28      # x10 = 6  (-1 + 7, wraps correctly)
    add  x11, x29, x29      # x11 = 0xFFFFFFFE (-1 + -1)
    add  x12, x27, x0       # x12 = 20 (add zero)

    # SUB
    sub  x13, x27, x28      # x13 = 13
    sub  x14, x28, x27      # x14 = -13 = 0xFFFFFFF3
    sub  x15, x27, x27      # x15 = 0  (x - x = 0)
    sub  x16, x0,  x28      # x16 = -7 = 0xFFFFFFF9 (0 - 7)

    # AND
    and  x17, x27, x28      # x17 = 20 & 7 = 4
    and  x18, x29, x28      # x18 = 0xFFFFFFFF & 7 = 7
    and  x19, x27, x0       # x19 = 0 (AND with 0)

    # OR
    or   x20, x27, x28      # x20 = 20 | 7 = 23
    or   x21, x29, x28      # x21 = 0xFFFFFFFF (OR with all 1s)
    or   x22, x27, x0       # x22 = 20 (OR with 0 = unchanged)

    # XOR
    xor  x23, x27, x28      # x23 = 20 ^ 7 = 19
    xor  x24, x27, x27      # x24 = 0  (x ^ x = 0)
    xor  x25, x29, x29      # x25 = 0  (0xFFFFFFFF ^ 0xFFFFFFFF = 0)
    xor  x26, x27, x0       # x26 = 20 (XOR with 0 = unchanged)

# ─────────────────────────────────────────────────────────────────
# SECTION 3: SHIFTS (R-type)
# ─────────────────────────────────────────────────────────────────

    addi x27, x0,  1
    addi x28, x0,  2
    addi x29, x0,  -1       # x29 = 0xFFFFFFFF
    addi x30, x0,  31

    # SLL
    sll  x3,  x27, x28      # x3  = 1 << 2 = 4
    sll  x4,  x27, x30      # x4  = 1 << 31 = 0x80000000
    sll  x5,  x29, x28      # x5  = 0xFFFFFFFF << 2 = 0xFFFFFFFC

    # SRL
    srl  x6,  x29, x28      # x6  = 0xFFFFFFFF >> 2 = 0x3FFFFFFF (logical)
    srl  x7,  x29, x30      # x7  = 0x00000001
    srl  x8,  x27, x28      # x8  = 1 >> 2 = 0

    # SRA
    sra  x9,  x29, x28      # x9  = 0xFFFFFFFF >> 2 = 0xFFFFFFFF (arithmetic)
    sra  x10, x29, x30      # x10 = 0xFFFFFFFF (all sign bits)
    addi x31, x0,  16
    sra  x11, x31, x28      # x11 = 4 (positive, same as SRL)
# ─────────────────────────────────────────────────────────────────
# SECTION 4: SET-LESS-THAN
# ─────────────────────────────────────────────────────────────────

    addi x27, x0,  5
    addi x28, x0,  10
    addi x29, x0,  -1       # x29 = 0xFFFFFFFF

    # SLT (signed)
    slt  x12, x29, x27      # x12 = 1 (-1 <s 5)
    slt  x13, x27, x29      # x13 = 0 (5 <s -1 = false)
    slt  x14, x27, x27      # x14 = 0 (equal)
    slt  x15, x27, x28      # x15 = 1 (5 <s 10)
    slt  x16, x28, x27      # x16 = 0 (10 <s 5 = false)

    # SLTU (unsigned)
    sltu x17, x27, x29      # x17 = 1 (5 <u 0xFFFFFFFF)
    sltu x18, x29, x27      # x18 = 0 (0xFFFFFFFF <u 5 = false)
    sltu x19, x27, x27      # x19 = 0 (equal)
    sltu x20, x0,  x27      # x20 = 1 (0 <u 5)

    # SLT vs SLTU distinction on same values
    slt  x21, x29, x27      # x21 = 1 (-1 <s 5 = true,  signed)
    sltu x22, x29, x27      # x22 = 0 (0xFFFFFFFF <u 5 = false, unsigned)

# ─────────────────────────────────────────────────────────────────
# SECTION 5: LUI / AUIPC
# ─────────────────────────────────────────────────────────────────

    # LUI
    lui  x23, 0x12345       # x23 = 0x12345000 (lower 12 bits zero)
    lui  x24, 0xFFFFF       # x24 = 0xFFFFF000
    lui  x25, 0x1           # x25 = 0x00001000
    lui  x26, 0x0           # x26 = 0x00000000

    # LUI + ADDI (32-bit constant load idiom)
    lui  x3,  0x12345       # x3  = 0x12345000
    addi x3,  x3,  0x678    # x3  = 0x12345678

    # LUI + ADDI with negative offset (upper bits adjusted by assembler idiom)
    lui  x4,  0xABCDE       # x4  = 0xABCDE000
    addi x4,  x4,  -1       # x4  = 0xABCDDFFF

    # AUIPC
    auipc x5, 0             # x5  = PC of this instruction
    auipc x6, 1             # x6  = PC + 0x1000
    auipc x7, 0             # x7  = PC of this instruction
    addi  x7, x7, 8         # x7  = PC_auipc + 8 (2 instructions ahead)

# ─────────────────────────────────────────────────────────────────
# SECTION 6: LOAD / STORE
# ─────────────────────────────────────────────────────────────────

    # x2 = base address of data_area (set by JAL at start)

    # SW / LW round-trip
    addi x27, x0,  0x7FF
    sw   x27, 0(x2)
    lw   x8,  0(x2)         # x8  = 0x000007FF

    # SW / LW negative
    addi x27, x0,  -1
    sw   x27, 4(x2)
    lw   x9,  4(x2)         # x9  = 0xFFFFFFFF

    # SH / LH (sign extension)
    addi x27, x0,  -1
    sw   x0,  8(x2)         # clear slot 2
    sh   x27, 8(x2)         # store 0xFFFF
    lh   x10, 8(x2)         # x10 = 0xFFFFFFFF (sign-extended)
    lhu  x11, 8(x2)         # x11 = 0x0000FFFF (zero-extended)

    # SH positive
    addi x27, x0,  0x7FF
    sw   x0,  12(x2)
    sh   x27, 12(x2)
    lh   x12, 12(x2)        # x12 = 0x000007FF
    lhu  x13, 12(x2)        # x13 = 0x000007FF

    # SB / LB (sign extension)
    addi x27, x0,  -1
    sw   x0,  16(x2)
    sb   x27, 16(x2)        # store 0xFF
    lb   x14, 16(x2)        # x14 = 0xFFFFFFFF (sign-extended)
    lbu  x15, 16(x2)        # x15 = 0x000000FF (zero-extended)

    # SB positive
    addi x27, x0,  42
    sw   x0,  20(x2)
    sb   x27, 20(x2)
    lb   x16, 20(x2)        # x16 = 42
    lbu  x17, 20(x2)        # x17 = 42

    # SB truncation (only lower 8 bits stored)
    addi x27, x0,  -1       # x27 = 0xFFFFFFFF
    sw   x0,  24(x2)
    sb   x27, 24(x2)        # stores 0xFF only
    lw   x18, 24(x2)        # x18 = 0x000000FF (upper 3 bytes untouched/zero)

    # SH truncation (only lower 16 bits stored)
    sw   x0,  28(x2)
    sh   x27, 28(x2)        # stores 0xFFFF only
    lw   x19, 28(x2)        # x19 = 0x0000FFFF (upper 2 bytes untouched/zero)

    # LH vs LHU vs LBU on same value — key distinction
    lh   x20, 8(x2)         # x20 = 0xFFFFFFFF (sign)
    lhu  x21, 8(x2)         # x21 = 0x0000FFFF (zero)
    lb   x22, 8(x2)         # x22 = 0xFFFFFFFF (sign, only reads 1 byte = 0xFF)
    lbu  x23, 8(x2)         # x23 = 0x000000FF (zero)

# ─────────────────────────────────────────────────────────────────
# SECTION 7: BRANCH
# ─────────────────────────────────────────────────────────────────

    addi x27, x0,  5
    addi x28, x0,  5
    addi x29, x0,  10
    addi x30, x0,  -1       # x30 = 0xFFFFFFFF

    # BEQ taken
    addi x3, x0, 0
    beq  x27, x28, beq_taken
    addi x3, x0, 0xFF
beq_taken:                  # x3 = 0

    # BEQ not-taken
    addi x4, x0, 0
    beq  x27, x29, beq_nt
    addi x4, x0, 1
beq_nt:                     # x4 = 1

    # BNE taken
    addi x5, x0, 0
    bne  x27, x29, bne_taken
    addi x5, x0, 0xFF
bne_taken:                  # x5 = 0

    # BNE not-taken
    addi x6, x0, 0
    bne  x27, x28, bne_nt
    addi x6, x0, 1
bne_nt:                     # x6 = 1

    # BLT taken
    addi x7, x0, 0
    blt  x27, x29, blt_taken
    addi x7, x0, 0xFF
blt_taken:                  # x7 = 0

    # BLT not-taken
    addi x8, x0, 0
    blt  x29, x27, blt_nt
    addi x8, x0, 1
blt_nt:                     # x8 = 1

    # BLT signed: -1 < 5 (true)
    addi x9, x0, 0
    blt  x30, x27, blt_signed
    addi x9, x0, 0xFF
blt_signed:                 # x9 = 0

    # BGE taken
    addi x10, x0, 0
    bge  x29, x27, bge_taken
    addi x10, x0, 0xFF
bge_taken:                  # x10 = 0

    # BGE not-taken
    addi x11, x0, 0
    bge  x27, x29, bge_nt
    addi x11, x0, 1
bge_nt:                     # x11 = 1

    # BGE equal (>= includes equal)
    addi x12, x0, 0
    bge  x27, x28, bge_eq
    addi x12, x0, 0xFF
bge_eq:                     # x12 = 0

    # BLTU taken: 5 <u 0xFFFFFFFF
    addi x13, x0, 0
    bltu x27, x30, bltu_taken
    addi x13, x0, 0xFF
bltu_taken:                 # x13 = 0

    # BLTU not-taken: 0xFFFFFFFF <u 5 = false
    addi x14, x0, 0
    bltu x30, x27, bltu_nt
    addi x14, x0, 1
bltu_nt:                    # x14 = 1

    # BLTU vs BLT distinction: -1 <s 5 (true) but 0xFFFFFFFF <u 5 (false)
    addi x15, x0, 0
    bltu x30, x27, bltu_sign_end
    addi x15, x0, 1         # x15 = 1 (BLTU not taken, correct)
bltu_sign_end:

    # BGEU taken: 0xFFFFFFFF >=u 5
    addi x16, x0, 0
    bgeu x30, x27, bgeu_taken
    addi x16, x0, 0xFF
bgeu_taken:                 # x16 = 0

    # BGEU not-taken
    addi x17, x0, 0
    bgeu x27, x30, bgeu_nt
    addi x17, x0, 1
bgeu_nt:                    # x17 = 1

    # BGEU equal (>= includes equal)
    addi x18, x0, 0
    bgeu x27, x28, bgeu_eq
    addi x18, x0, 0xFF
bgeu_eq:                    # x18 = 0

# ─────────────────────────────────────────────────────────────────
# SECTION 8: JAL / JALR
# ─────────────────────────────────────────────────────────────────

    # JAL: jump forward, store return address
    addi x19, x0, 0
    jal  x1, jal_target
    addi x19, x0, 0xFF      # skipped
jal_target:                  # x19 = 0

    # JAL: x0 as rd (discard return address)
    addi x20, x0, 0
    jal  x0, jal_x0_target
    addi x20, x0, 0xFF      # skipped
jal_x0_target:               # x20 = 0, x0 still = 0

    # JALR: function call and return (real-world pattern)
    jal  x1, func_add       # call func_add, x1 = return address
                             # x22 = 100 after return
    jal  x1, func_max       # call func_max
                             # x23 = 50 after return

    jal  x0, section9       # done with JAL/JALR section

# ─── func_add: computes x22 = 42 + 58 = 100 ───────────────────
func_add:
    addi x22, x0,  42
    addi x27, x0,  58
    add  x22, x22, x27
    jalr x0,  x1,  0        # return

# ─── func_max: computes x23 = max(30, 50) = 50 ────────────────
func_max:
    addi x27, x0,  30
    addi x28, x0,  50
    bge  x28, x27, max_ret
    addi x28, x27, 0
max_ret:
    addi x23, x28, 0
    jalr x0,  x1,  0        # return

# ─────────────────────────────────────────────────────────────────
# SECTION 9: COMBINATIONS AND REAL-WORLD SCENARIOS
# ─────────────────────────────────────────────────────────────────

section9:

    # ── Scenario 1: Absolute value ────────────────────────────
    # abs(x) using SUB and BLT
    # compute abs(-42)
    addi x27, x0,  -42
    addi x3,  x27, 0        # x3 = -42
    bge  x3,  x0,  abs_done # if x3 >= 0, skip negation
    sub  x3,  x0,  x3       # x3 = 0 - x3 = 42
abs_done:                   # x3 = 42

    # ── Scenario 2: Count set bits (popcount) of 0b10110101 ──
    # Manual 8-bit popcount using shifts and AND
    addi x27, x0,  0xB5     # x27 = 0b10110101 = 181
    addi x4,  x0,  0        # x4  = count

    andi x28, x27, 1        # check bit 0
    add  x4,  x4,  x28
    srli x27, x27, 1

    andi x28, x27, 1        # check bit 1
    add  x4,  x4,  x28
    srli x27, x27, 1

    andi x28, x27, 1        # check bit 2
    add  x4,  x4,  x28
    srli x27, x27, 1

    andi x28, x27, 1        # check bit 3
    add  x4,  x4,  x28
    srli x27, x27, 1

    andi x28, x27, 1        # check bit 4
    add  x4,  x4,  x28
    srli x27, x27, 1

    andi x28, x27, 1        # check bit 5
    add  x4,  x4,  x28
    srli x27, x27, 1

    andi x28, x27, 1        # check bit 6
    add  x4,  x4,  x28
    srli x27, x27, 1

    andi x28, x27, 1        # check bit 7
    add  x4,  x4,  x28
                            # x4 = 5 (0b10110101 has 5 set bits)

    # ── Scenario 3: Integer multiply by 10 using shifts/adds ─
    # x * 10 = (x << 3) + (x << 1)
    addi x27, x0,  7        # x27 = 7
    slli x28, x27, 3        # x28 = 7 * 8 = 56
    slli x29, x27, 1        # x29 = 7 * 2 = 14
    add  x5,  x28, x29      # x5  = 70

    # ── Scenario 4: Extract bitfield ─────────────────────────
    # Extract bits [7:4] from 0xABCD
    lui  x27, 0xABCDE       # x27 = 0xABCDE000... use simpler value
    addi x27, x0,  0xAB     # x27 = 0xAB = 0b10101011
    srli x27, x27, 4        # x27 = 0x0A = 0b00001010
    andi x6,  x27, 0xF      # x6  = 0x0A (bits [7:4] of 0xAB)

    # ── Scenario 5: Byte swap lower 16 bits ──────────────────
    # swap bytes of 0xAABB → 0xBBAA
    addi x27, x0,  0         # build 0xAABB
    ori  x27, x27, 0xAA
    slli x27, x27, 8
    ori  x27, x27, 0xBB      # x27 = 0xAABB

    andi x28, x27, 0xFF      # x28 = 0x00BB (low byte)
    srli x29, x27, 8         # x29 = 0x00AA (high byte)
    slli x28, x28, 8         # x28 = 0xBB00
    or   x7,  x28, x29       # x7  = 0xBBAA

    # ── Scenario 6: Store and reload multiple values ──────────
    addi x27, x0,  111
    addi x28, x0,  222
    addi x29, x0,  -333
    sw   x27, 0(x2)
    sw   x28, 4(x2)
    sw   x29, 8(x2)
    lw   x8,  0(x2)         # x8  = 111
    lw   x9,  4(x2)         # x9  = 222
    lw   x10, 8(x2)         # x10 = -333 = 0xFFFFFEB3

    # ── Scenario 7: Loop — sum 1 to 5 ────────────────────────
    addi x27, x0,  1        # counter = 1
    addi x28, x0,  5        # limit = 5
    addi x11, x0,  0        # sum = 0
loop_sum:
    add  x11, x11, x27      # sum += counter
    addi x27, x27, 1        # counter++
    ble_label:
    bgt_check:
    blt  x27, x28, loop_sum # if counter < limit, loop
    add  x11, x11, x27      # add final value (5 not added by branch)
                             # wait: when x27=5, blt fails, so we add 5 here
                             # sum = 1+2+3+4 = 10, then add 5 = 15
                             # x11 = 15

    # ── Scenario 8: Fibonacci (first 8 terms) ────────────────
    # F: 1, 1, 2, 3, 5, 8, 13, 21
    addi x27, x0,  1        # F(1) = 1
    addi x28, x0,  1        # F(2) = 1
    add  x29, x27, x28      # F(3) = 2
    add  x30, x28, x29      # F(4) = 3
    add  x31, x29, x30      # F(5) = 5
    add  x12, x30, x31      # F(6) = 8
    add  x13, x31, x12      # F(7) = 13
    add  x14, x12, x13      # F(8) = 21

    # ── Scenario 9: Sign extension verification ───────────────
    # Store a negative byte, load as signed and unsigned
    addi x27, x0, -50       # x27 = 0xFFFFFFCE
    sw   x0,  12(x2)        # clear
    sb   x27, 12(x2)        # store 0xCE
    lb   x15, 12(x2)        # x15 = 0xFFFFFFCE (sign-extended)
    lbu  x16, 12(x2)        # x16 = 0x000000CE (zero-extended)

    # ── Scenario 10: PC-relative address calculation ──────────
    auipc x17, 0            # x17 = PC of this instruction
    addi  x17, x17, 12      # x17 = address 3 instructions ahead
                             # (used in real code for position-independent addressing)
    ebreak
