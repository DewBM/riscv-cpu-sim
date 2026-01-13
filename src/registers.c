#include "registers.h"

void reg_init(struct Registers *reg) {
    reg->regs[0] = 0;
}

void write_reg(struct Registers *reg, uint8_t rd, uint32_t rdVal, uint8_t write_enable){
    if (write_enable == 0) {
//	fprintf(stderr, "Cannot write: write_enable is not asserted\n");
//	exit(EXIT_FAILURE);
	return;
    }
    if (rd == 0) {
	fprintf(stderr, "Cannot write to reg x0: x0 is hardwired to 0\n");
	exit(EXIT_FAILURE);
    }

    reg->regs[rd] = rdVal;
}


void read_reg(struct Registers *reg, uint8_t rs1, uint8_t rs2, uint32_t *rs1Val, uint32_t *rs2Val) {
    *rs1Val = rs1 < 31 ? reg->regs[rs1] : 0;
    *rs2Val = rs2 < 32 ? reg->regs[rs2] : 0;
}
