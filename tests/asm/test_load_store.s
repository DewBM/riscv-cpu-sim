# test_load_store.s — Tests implemented LOAD/STORE instructions: LW, SW
#
# Memory layout trick: JAL jumps over the data_area,
# x31 = address of data_area. Works at any load address
# (simulator at 0x0, QEMU at 0x10000).
#
# Results: x2, x3

.section .text
.global _start

_start:
    # JAL stores PC+4 into x31; data_area is exactly at PC+4, so x31 = &data_area
    jal  x31, main_code

data_area:
    .word 0                  # slot 0: offset 0 from x31
    .word 0                  # slot 1: offset 4

main_code:
    # x31 = address of data_area

    # SW / LW positive value round-trip
    addi x1, x0, 0x7FF      # x1 = 2047 = 0x000007FF
    sw   x1, 0(x31)
    lw   x2, 0(x31)         # x2 = 0x000007FF

    # SW / LW negative value (checks sign bits preserved)
    addi x1, x0, -1         # x1 = 0xFFFFFFFF
    sw   x1, 4(x31)
    lw   x3, 4(x31)         # x3 = 0xFFFFFFFF

    ebreak
