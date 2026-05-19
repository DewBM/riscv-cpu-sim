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

    ebreak
