#ifndef CPU_H
#define CPU_H

#include <stdint.h>

#include "memory.h"
#include "registers.h"
#include "pipeline.h"

#define MEM_SIZE 1024 * 1024

struct CPU {
    uint32_t pc;
    struct Memory *mem;
    struct Registers *reg;
    struct Pipeline pipeline;
    bool halt;
};

void cpu_init(struct CPU *cpu);

void cpu_cycle(struct CPU *cpu);
#endif
