#include "../../include/stages/inst_decode.h"

void id_stage(struct CPU *cpu) {
    struct IF_ID *in = &cpu->pipeline.if_id;
    struct ID_EX *out = &cpu->pipeline.id_ex;

    if (in->inst == 0x00100073) {   // EBREAK
	cpu->halt = true;
	return;
    }

    struct Decoded_Instr d = decode(in->inst);

    read_reg(cpu->reg, d.rs1, d.rs2, &out->rs1Val, &out->rs2Val); // read registers and pass to the ex stage through id_ex pipeline registers

    out->imm = d.imm;
    out->rd = d.rd;
    out->control = control_generate(&d);
}
