#include "../../include/stages/inst_fetch.h"

void if_stage(struct CPU *cpu) {
    struct IF_ID *out = &cpu->pipeline.if_id;
    out->inst = mem_read(cpu->mem, cpu->pc);	// fetch the instruction from memory and store it in the if_id pipeline register

    cpu->pc += 4;
}
