#include "../../include/stages/inst_execute.h"

struct Flags {
    bool zero;
    uint8_t sign; // 0 = positive, 1 = negative
    bool overflow;
    bool carry;
};

static uint32_t alu(struct Flags *flags, uint32_t val1, uint32_t val2, enum Alu_Op alu_op) {
    switch (alu_op) {
	case ALU_ADD: return val1 + val2;
	case ALU_SUB:
	    uint32_t res = val1 - val2;
	    flags->zero = res == 0 ? true : false;
	    flags->sign = ((res >> 31) & 0x1);
	    return res;
	case ALU_SLT: return 0; // not implemented yet
	case ALU_OR: return val1 | val2;
	case ALU_AND: return val1 & val2;
    }
    return 0;
}

uint32_t pc_target(uint32_t pc, uint32_t rs1Val, uint32_t imm, enum PC_Target_Src pc_target_src) {
    switch (pc_target_src) {
	case RS1_VAL: return rs1Val + imm;
	case PC: return pc + imm;
    }
}


uint32_t pc_plus4(uint32_t pc) {
    return pc + 4;
}


static bool branch(struct Flags *flags, enum Branch_Type branch_type) {
    switch (branch_type) {
	case BEQ: return flags->zero == true ? true : false;
	case BNE: return flags->zero == false ? true : false;
	case BLT: return (flags->zero == false && flags->sign == 1) ? true : false;
	case BGE: return (flags->zero == true || flags->sign == 0) ? true : false;
    }
    return false;
}

void ex_stage(struct CPU *cpu) {
    struct ID_EX *in = &cpu->pipeline.id_ex;
    struct EX_MEM *out = &cpu->pipeline.ex_mem;

    struct Flags flags;

    uint32_t result = alu(
	&flags,
	in->rs1Val,
	in->control.alu_src == 0x00 ? in->rs2Val : in->imm,
	in->control.alu_control
    );

    bool branch_taken = false;
    if (in->control.branch == 1) {
	branch_taken = branch(&flags, in->control.branch_type);
    }

    //cpu->pc += branch_taken ? in->imm : 4;
    switch (in->control.pc_src) {
	case PC_PLUS4:
	    cpu->pc = pc_plus4(cpu->pc);
	    break;
	case PC_TARGET:
	    cpu->pc = pc_target(cpu->pc, in->rs1Val, in->imm, in->control.pc_target_src);
	    break;
    }

    out->rd = in->rd;
    out->pcPlus4 = in->pcPlus4;
    out->alu_res = result;
    out->rs2Val = in->rs2Val;
    out->control = in->control;
}
