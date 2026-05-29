# test_lui_auipc.s — Tests LUI and AUIPC instructions
# Results: x1..x8

.section .text
.global _start

_start:
    # LUI basic: lower 12 bits must be zero
    lui  x1, 0x12345         # x1 = 0x12345000

    # LUI max upper immediate
    lui  x2, 0xFFFFF         # x2 = 0xFFFFF000

    # LUI minimum non-zero
    lui  x3, 0x1             # x3 = 0x00001000

    # LUI zero
    lui  x4, 0x0             # x4 = 0x00000000

    # LUI + ADDI (common idiom — load full 32-bit value)
    lui  x5, 0x12345         # x5 = 0x12345000
    addi x5, x5, 0x678       # x5 = 0x12345678

    # AUIPC with 0: rd = PC of this instruction
    auipc x6, 0              # x6 = address of this instruction

    # AUIPC with non-zero: rd = PC + 0x1000
    auipc x7, 1              # x7 = address of this instruction + 0x1000

    # AUIPC + ADDI (common idiom — PC-relative address calculation)
    auipc x8, 0              # x8 = PC
    addi  x8, x8, 8          # x8 = PC + 8 (address of auipc + 2 instructions)

    ebreak
