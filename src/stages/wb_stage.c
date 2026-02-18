#include "../../include/stages/wb_stage.h"

void wb_stage(struct CPU *cpu) {
    struct MEM_WB *in = &cpu->pipeline.mem_wb;

    uint32_t rdVal;
    switch (in->control.result_src) {
	case ALU:
	    rdVal = in->alu_res;
	    break;
	case MEM:
	    rdVal = in->read_data;
	    break;
	case PC_PLUS4:
	    rdVal = in->pcPlus4;
	    break;
    }

/*
    if (in->control.result_src == 0) {
	rdVal = in->alu_res;
    }
    else {
	rdVal = in->read_data;
    }
*/
    write_reg(cpu->reg, in->rd, rdVal, in->control.reg_write);
}
