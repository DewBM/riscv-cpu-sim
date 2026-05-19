# test_jal_jalr.s — Tests JAL and JALR
#
# KNOWN BUGS (will cause FAIL):
#   JAL:  imm[19:12] decoded from bits[28:21] instead of bits[19:12]
#         → jump target is wrong for any offset; simulator will likely crash
#   JALR: decoded as R-type (opcode table says R) instead of I-type
#         → immediate is never decoded (d.imm stays 0)
#         → JALR jumps to rs1 + 0 instead of rs1 + imm
#
# If simulator crashes/hangs, run_tests.py reports TIMEOUT.

.section .text
.global _start

_start:
    #==============================
    # JAL test
    # Expected: x2 = address of (addi x1, x0, 0xFF) [= PC_jal + 4]
    #           x1 = 0   (bad addi was skipped)
    # Bug:      simulator jumps to wrong address entirely
    #==============================
    addi x1, x0, 0
    jal  x2, jal_target      # x2 = PC+4; jump to jal_target (offset = +8)
    addi x1, x0, 0xFF        # SHOULD BE SKIPPED
jal_target:

    #==============================
    # JALR test
    # Use JAL to capture current PC in x3 (this JAL also has the bug).
    # In QEMU (correct): x3 = address of label 1f
    # In simulator (buggy JAL): x3 = garbage → rest of test also wrong
    #
    # Expected: x4 = 0   (bad addi was skipped)
    #           x5 = return address stored by JALR
    # Bug:      JALR uses imm=0 → jumps to x3+0 instead of x3+offset
    #==============================
    addi x4, x0, 0
    jal  x3, 1f              # x3 = address of 1f (offset = +4)
1:
    # x3 = address of this instruction (1f)
    # jalr_dest is 12 bytes ahead: skip 2 bad instructions
    jalr x5, x3, 12          # jump to x3+12 = jalr_dest; x5 = PC+4
    addi x4, x0, 0xFF        # SHOULD BE SKIPPED
    addi x4, x0, 0xFF        # SHOULD BE SKIPPED (filler for offset)
jalr_dest:
    # x4 = 0 if both JAL and JALR worked correctly

    ebreak
