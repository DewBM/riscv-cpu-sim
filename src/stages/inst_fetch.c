#include "stages/inst_fetch.h"

void if_stage(struct CPU *cpu) {
    struct IF_ID *out = &cpu->pipeline.if_id;

	//    switch (in->control.pc_src) {
	// case PC_PLUS4:
	//     cpu->pc = pc_plus4(cpu->pc);
	//     break;
	// case PC_TARGET:
	//     cpu->pc = pc_target(cpu->pc, in->rs1Val, in->imm, in->control.pc_target_src);
	//     break;
	//    }

    out->pc = cpu->pc;
    out->inst = mem_read32(cpu->mem, cpu->pc);	// fetch the instruction from memory and store it in the if_id pipeline register

    cpu->pc = cpu->pc+4;
}
