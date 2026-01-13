#ifndef REGISTERS_H
#define REGISTERS_H

#include <stdint.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>

#define NUM_REGS 32

struct Registers {
    uint32_t regs[NUM_REGS];
};

void reg_init(struct Registers *reg);

void read_reg(struct Registers *reg, uint8_t rs1, uint8_t rs2, uint32_t *rs1Val, uint32_t *rs2Val);

void write_reg(struct Registers *reg, uint8_t rd, uint32_t rdVal, uint8_t write_enable);

#endif
