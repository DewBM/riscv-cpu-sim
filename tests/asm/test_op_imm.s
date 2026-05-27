# test_op_imm.s — Tests implemented OP-IMM instructions: ADDI, ANDI, ORI, XORI
# Results: x1..x5

.section .text
.global _start

_start:
    # ADDI positive: x1 = 0 + 100 = 100 = 0x00000064
    addi x1, x0, 100

    # ADDI negative: x2 = 0 + (-50) = -50 = 0xFFFFFFCE
    addi x2, x0, -50

    # Setup operand for bitwise tests (spaced apart to avoid hazards)
    addi x20, x0, 0         # x20 = 0 (padding)
    addi x21, x0, 0         # x21 = 0 (padding)
    addi x22, x0, 255       # x22 = 0xFF

    # ANDI: x3 = 0xFF & 0x0F = 15 = 0x0000000F
    andi x3, x22, 15

    # ORI: x4 = 0 | 0xFF = 255 = 0x000000FF
    ori  x4, x0, 255

    # XORI: x5 = 0xFF ^ 0x0F = 240 = 0x000000F0
    xori x5, x22, 15

    # SLTI true: x6 = (-1 <s 7) ? 1 : 0 = 1
    # x23 = -1 = 0xFFFFFFFF (signed: -1, less than 7)
    addi x23, x0, -1
    slti x6, x23, 7

    # SLTI false: x7 = (10 <s 7) ? 1 : 0 = 0
    addi x24, x0, 10
    slti x7, x24, 7

    # SLTI edge: x8 = (0 <s 0) ? 1 : 0 = 0  (equal, not less)
    slti x8, x0, 0

    # SLTI negative imm: x9 = (-5 <s -3) ? 1 : 0 = 1
    addi x25, x0, -5
    slti x9, x25, -3

    # Setup operands
    addi x25, x0, 1          # x25 = 1
    addi x26, x0, -1         # x26 = 0xFFFFFFFF

    # SLLI: x10 = 1 << 5 = 32 = 0x00000020
    slli x10, x25, 5

    # SLLI: x11 = 1 << 31 = 0x80000000 (shift into sign bit)
    slli x11, x25, 31

    # SRLI: x12 = 0xFFFFFFFF >> 4 = 0x0FFFFFFF (logical, fills with 0)
    srli x12, x26, 4

    # SRLI: x13 = 0xFFFFFFFF >> 31 = 0x00000001 (only sign bit remains)
    srli x13, x26, 31

    # SRAI: x14 = 0xFFFFFFFF >> 4 = 0xFFFFFFFF (arithmetic, fills with sign bit 1)
    srai x14, x26, 4

    # SRAI: x15 = 0xFFFFFFFF >> 31 = 0xFFFFFFFF (all sign bits)
    srai x15, x26, 31

    # SRAI positive: x16 = 16 >> 2 = 4 (positive, same as logical)
    addi x27, x0, 16
    srai x16, x27, 2

    # Setup
    addi x28, x0, -1         # x28 = 0xFFFFFFFF (large unsigned)

    # SLTIU: x17 = (7 <u 100) ? 1 : 0 = 1  (small unsigned < imm)
    addi x29, x0, 7
    sltiu x17, x29, 100

    # SLTIU: x18 = (0xFFFFFFFF <u 100) ? 1 : 0 = 0  (large unsigned > imm)
    sltiu x18, x28, 100

    # SLTIU: x19 = (7 <u 7) ? 1 : 0 = 0  (equal, not less)
    sltiu x19, x29, 7

    # SLTIU: x20 = (0 <u 1) ? 1 : 0 = 1  (zero is smallest unsigned)
    sltiu x20, x0, 1

    # Setup
    addi x30, x0, 15         # x30 = 0x0000000F

    # XORI: x21 = 0x0F ^ 0x0F = 0x00000000
    xori x21, x30, 15

    # XORI: x22 = 0x0F ^ 0x00 = 0x0000000F  (XOR with 0 = itself)
    xori x22, x30, 0

    # XORI: x23 = 0x0F ^ -1 = 0xFFFFFFF0  (XOR with -1 = bitwise NOT)
    xori x23, x30, -1

    # XORI: x24 = 0 ^ -1 = 0xFFFFFFFF
    xori x24, x0, -1

    ebreak
