#include "stages/mem_stage.h"
#include "control.h"
#include "memory.h"
#include "utils.h"

void mem_stage(struct CPU *cpu) {
    struct EX_MEM *in = &cpu->pipeline.ex_mem;
    struct MEM_WB *out = &cpu->pipeline.mem_wb;

    if (in->control.mem_write == 1) {
	mem_write(cpu->mem, in->alu_res, in->rs2Val, in->control.mem_write);
    }
    else {
	switch (in->control.ls_type) {
	    case BYTE:
		out->read_data = sign_extend(mem_read8(cpu->mem, in->alu_res), 8*BYTE);
		break;
	    case HALF_WORD:
		out->read_data = sign_extend(mem_read16(cpu->mem, in->alu_res), 8*HALF_WORD);
		break;
	    case WORD:
		out->read_data = mem_read32(cpu->mem, in->alu_res);
		break;
	}
    }

    out->control = in->control;
    out->alu_res = in->alu_res;
    out->rd = in->rd;
    out->pcPlus4 = in->pcPlus4;
}
