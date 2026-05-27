# test_op.s — Tests implemented R-type (OP) instructions: ADD, SUB, AND, OR
# Operands: x20=20, x21=7
# Results:  x1..x4

.section .text
.global _start

_start:
    addi x20, x0, 20        # x20 = 20
    addi x21, x0, 7         # x21 = 7

    # ADD: x1 = 20 + 7 = 27 = 0x0000001B
    add  x1, x20, x21

    # SUB: x2 = 20 - 7 = 13 = 0x0000000D
    sub  x2, x20, x21

    # AND: x3 = 20 & 7 = 4 = 0x00000004
    #   0b10100 & 0b00111 = 0b00100
    and  x3, x20, x21

    # OR:  x4 = 20 | 7 = 23 = 0x00000017
    #   0b10100 | 0b00111 = 0b10111
    or   x4, x20, x21

    # Setup operands
    addi x22, x0, -1         # x22 = 0xFFFFFFFF (-1 signed)
    addi x23, x0, 2          # x23 = 2 (shift amount)
    addi x24, x0, 31         # x24 = 31 (max shift)

    # SLT: x5 = (-1 <s 7) ? 1 : 0 = 1  (negative < positive)
    slt  x5, x22, x21        # x21 = 7 from existing setup

    # SLT: x6 = (20 <s 7) ? 1 : 0 = 0  (false case)
    slt  x6, x20, x21        # x20 = 20 from existing setup

    # SLT: x7 = (-1 <s -1) ? 1 : 0 = 0  (equal, not less)
    slt  x7, x22, x22

    # SLL: x8 = 1 << 2 = 4 = 0x00000004
    addi x25, x0, 1
    sll  x8, x25, x23

    # SLL: x9 = 1 << 31 = 0x80000000  (shift into sign bit)
    sll  x9, x25, x24

    # SRL: x10 = 0xFFFFFFFF >> 2 = 0x3FFFFFFF  (logical, fills with 0)
    srl  x10, x22, x23

    # SRL: x11 = 0xFFFFFFFF >> 31 = 0x00000001
    srl  x11, x22, x24

    # SRA: x12 = 0xFFFFFFFF >> 2 = 0xFFFFFFFF  (arithmetic, fills with 1)
    sra  x12, x22, x23

    # SRA: x13 = 0xFFFFFFFF >> 31 = 0xFFFFFFFF  (all sign bits)
    sra  x13, x22, x24

    # SRA positive: x14 = 16 >> 2 = 4  (positive, same as SRL)
    addi x26, x0, 16
    sra  x14, x26, x23

    # Setup
    addi x27, x0, -1         # x27 = 0xFFFFFFFF (large unsigned)
    addi x28, x0, 7          # x28 = 7

    # SLTU: x15 = (7 <u 0xFFFFFFFF) ? 1 : 0 = 1  (small unsigned < large unsigned)
    sltu x15, x28, x27

    # SLTU: x16 = (0xFFFFFFFF <u 7) ? 1 : 0 = 0  (false case)
    sltu x16, x27, x28

    # SLTU: x17 = (7 <u 7) ? 1 : 0 = 0  (equal, not less)
    sltu x17, x28, x28

    # SLTU: x18 = (0 <u 0xFFFFFFFF) ? 1 : 0 = 1  (zero is smallest unsigned)
    sltu x18, x0, x27

    # Setup
    addi x27, x0, -1         # x27 = 0xFFFFFFFF
    addi x28, x0, 15         # x28 = 0x0000000F

    # XOR: x15 = 20 ^ 7 = 19 = 0x00000013
    #   0b10100 ^ 0b00111 = 0b10011
    xor  x15, x20, x21       # x20=20, x21=7 from existing setup

    # XOR: x16 = 0xFFFFFFFF ^ 0x0000000F = 0xFFFFFFF0
    xor  x16, x27, x28

    # XOR: x17 = x ^ x = 0  (any value XOR itself = 0)
    xor  x17, x20, x20

    # XOR: x18 = x ^ 0 = x  (any value XOR 0 = itself)
    xor  x18, x20, x0

    ebreak
