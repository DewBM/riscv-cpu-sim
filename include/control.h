#ifndef CONTROL_H
#define CONTROL_H

#include <stdint.h>
#include <stdbool.h>

#include "decode.h"

enum ALU_Function {
    ADD = 0,
    SUB = 1,
    STL = 5,
    OR = 3,
    AND = 2
};

struct Control {
    uint8_t result_src;
    uint8_t alu_src;
    enum ALU_Function alu_control;
    uint8_t reg_write;
    uint8_t mem_write;
};

struct Control control_generate(struct Decoded_Instr *d);

#endif
