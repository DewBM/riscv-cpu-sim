# test_load_store.s — Tests implemented LOAD/STORE instructions: LW, SW, LH, LB
#
# Memory layout trick: JAL jumps over the data_area,
# x31 = address of data_area. Works at any load address.
#
# Results: x2, x3, x5, x6, x7, x8

.section .text
.global _start

_start:
    # JAL stores PC+4 into x31; data_area is exactly at PC+4, so x31 = &data_area
    jal  x31, main_code

data_area:
    .word 0                  # slot 0: offset  0 (LW/SW tests)
    .word 0                  # slot 1: offset  4 (LW/SW tests)
    .word 0                  # slot 2: offset  8 (LH tests)
    .word 0                  # slot 3: offset 12 (LB tests)

main_code:
    # x31 = address of data_area

    #--- SW / LW positive value round-trip ---
    addi x1, x0, 0x7FF      # x1 = 0x000007FF
    sw   x1, 0(x31)
    lw   x2, 0(x31)         # x2 = 0x000007FF

    #--- SW / LW negative value ---
    addi x1, x0, -1         # x1 = 0xFFFFFFFF
    sw   x1, 4(x31)
    lw   x3, 4(x31)         # x3 = 0xFFFFFFFF

    #--- LH negative (sign extension from bit 15) ---
    addi x4, x0, -1
    sw   x4, 8(x31)         # store 0xFFFFFFFF at slot 2
    lh   x5, 8(x31)         # x5 = 0xFFFFFFFF (sign-extended 0xFFFF)

    #--- LH positive (sign extension must not corrupt) ---
    addi x4, x0, 0x7FF
    sw   x4, 12(x31)
    lh   x6, 12(x31)        # x6 = 0x000007FF

    #--- LB negative (sign extension from bit 7) ---
    addi x4, x0, -1
    sw   x4, 8(x31)
    lb   x7, 8(x31)         # x7 = 0xFFFFFFFF (sign-extended 0xFF)

    #--- LB positive (sign extension must not corrupt) ---
    addi x4, x0, 42
    sw   x4, 12(x31)
    lb   x8, 12(x31)        # x8 = 0x0000002A

    #--- LHU (zero extend, upper bits must be 0) ---
    addi x4, x0, -1
    sw   x4, 8(x31)         # store 0xFFFFFFFF at slot 2
    lhu  x9, 8(x31)         # x9 = 0x0000FFFF (zero-extended, NOT 0xFFFFFFFF)

    #--- LBU (zero extend, upper bits must be 0) ---
    lb   x10, 8(x31)        # x10 = 0xFFFFFFFF (reuse slot 2, sign-extended)
    lbu  x11, 8(x31)        # x11 = 0x000000FF (zero-extended, NOT 0xFFFFFFFF)

    ebreak
