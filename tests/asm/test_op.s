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

    ebreak
