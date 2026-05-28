#include "cpu.h"
#include "stages/inst_fetch.h"
#include "stages/inst_decode.h"
#include "stages/inst_execute.h"
#include "stages/mem_stage.h"
#include "stages/wb_stage.h"

void cpu_init(struct CPU *cpu) {
    cpu->pc = 0x10000;

    cpu->mem = malloc(sizeof(struct Memory));
    cpu->reg = malloc(sizeof(struct Registers));

    mem_init(cpu->mem, MEM_SIZE);
    reg_init(cpu->reg);
}

void cpu_cycle(struct CPU *cpu) {
    if_stage(cpu);
    id_stage(cpu);
    ex_stage(cpu);
    mem_stage(cpu);
    wb_stage(cpu);
}
