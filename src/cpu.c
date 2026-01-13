#include "../include/cpu.h"
#include "../include/stages/inst_fetch.h"
#include "../include/stages/inst_decode.h"
#include "../include/stages/inst_execute.h"
#include "../include/stages/mem_stage.h"
#include "../include/stages/wb_stage.h"

void cpu_init(struct CPU *cpu) {
    cpu->pc = 0x0;

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
