# test_branch.s — Tests all 6 BRANCH instructions, taken and not-taken
#
# Convention:
#   Result register = 0  → branch was TAKEN    (bad addi was skipped)
#   Result register = 1  → branch was NOT TAKEN (fell through, set to 1)
#
# Operands: x20=5, x21=5, x22=10, x23=-1(0xFFFFFFFF)
# Results:  x1..x12

.section .text
.global _start

_start:
    addi x20, x0, 5         # x20 = 5
    addi x21, x0, 5         # x21 = 5  (equal to x20)
    addi x22, x0, 10        # x22 = 10
    addi x23, x0, -1        # x23 = 0xFFFFFFFF

    #--- BEQ taken: x20 == x21 (5 == 5) → skip bad addi → x1 = 0 ---
    addi x1, x0, 0
    beq  x20, x21, beq_t_end
    addi x1, x0, 0xFF
beq_t_end:

    #--- BEQ not-taken: x20 != x22 (5 != 10) → fall through → x2 = 1 ---
    addi x2, x0, 0
    beq  x20, x22, beq_nt_end
    addi x2, x0, 1
beq_nt_end:

    #--- BNE taken: x20 != x22 (5 != 10) → skip → x3 = 0 ---
    addi x3, x0, 0
    bne  x20, x22, bne_t_end
    addi x3, x0, 0xFF
bne_t_end:

    #--- BNE not-taken: x20 == x21 (5 == 5) → fall through → x4 = 1 ---
    addi x4, x0, 0
    bne  x20, x21, bne_nt_end
    addi x4, x0, 1
bne_nt_end:

    #--- BLT taken: x20 <s x22 (5 < 10) → skip → x5 = 0 ---
    addi x5, x0, 0
    blt  x20, x22, blt_t_end
    addi x5, x0, 0xFF
blt_t_end:

    #--- BLT not-taken: x22 <s x20 (10 < 5) false → fall through → x6 = 1 ---
    addi x6, x0, 0
    blt  x22, x20, blt_nt_end
    addi x6, x0, 1
blt_nt_end:

    #--- BGE taken: x22 >=s x20 (10 >= 5) → skip → x7 = 0 ---
    addi x7, x0, 0
    bge  x22, x20, bge_t_end
    addi x7, x0, 0xFF
bge_t_end:

    #--- BGE not-taken: x20 >=s x22 (5 >= 10) false → fall through → x8 = 1 ---
    addi x8, x0, 0
    bge  x20, x22, bge_nt_end
    addi x8, x0, 1
bge_nt_end:

    #--- BLTU taken: x20 <u x23 (5 <u 0xFFFFFFFF) → skip → x9 = 0 ---
    addi x9, x0, 0
    bltu x20, x23, bltu_t_end
    addi x9, x0, 0xFF
bltu_t_end:

    #--- BLTU not-taken: x23 <u x20 (0xFFFF <u 5) false → fall through → x10 = 1 ---
    addi x10, x0, 0
    bltu x23, x20, bltu_nt_end
    addi x10, x0, 1
bltu_nt_end:

    #--- BGEU taken: x23 >=u x20 (0xFFFFFFFF >=u 5) → skip → x11 = 0 ---
    addi x11, x0, 0
    bgeu x23, x20, bgeu_t_end
    addi x11, x0, 0xFF
bgeu_t_end:

    #--- BGEU not-taken: x20 >=u x23 (5 >=u 0xFFFFFFFF) false → fall through → x12 = 1 ---
    addi x12, x0, 0
    bgeu x20, x23, bgeu_nt_end
    addi x12, x0, 1
bgeu_nt_end:

    ebreak
