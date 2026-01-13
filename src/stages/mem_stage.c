#include "../../include/stages/mem_stage.h"

void mem_stage(struct CPU *cpu) {
    struct EX_MEM *in = &cpu->pipeline.ex_mem;
    struct MEM_WB *out = &cpu->pipeline.mem_wb;

    if (in->control.mem_write == 1) {
	mem_write(cpu->mem, in->alu_res, in->rs2Val, in->control.mem_write);
    }
    else {
	out->read_data = mem_read(cpu->mem, in->alu_res);
    }

    out->control = in->control;
    out->alu_res = in->alu_res;
    out->rd = in->rd;
}
