#include "../../include/stages/inst_execute.h"

static uint32_t alu(uint32_t val1, uint32_t val2, enum ALU_Function function) {
    switch (function) {
	case ADD: return val1 + val2;
	case SUB: return val1 - val2;
	case STL: return 0; // not implemented yet
	case OR: return val1 | val2;
	case AND: return val1 & val2;
    }
    return 0;
}

void ex_stage(struct CPU *cpu) {
    struct ID_EX *in = &cpu->pipeline.id_ex;
    struct EX_MEM *out = &cpu->pipeline.ex_mem;

    uint32_t result = alu(
	in->rs1Val,
	in->control.alu_src == 0x00 ? in->rs2Val : in->imm,
	in->control.alu_control
    );

    out->rd = in->rd;
    out->alu_res = result;
    out->rs2Val = in->rs2Val;
    out->control = in->control;
}
