#ifndef CONTROL_H
#define CONTROL_H

#include <stdint.h>
#include <stdbool.h>

#include "decode.h"

/*
    enum ALU_Function {
    ADD = 0,
    SUB = 1,
    STL = 5,
    OR = 3,
    AND = 2
};
*/

enum Alu_Op {
    ALU_ADD,
    ALU_SUB,
    ALU_AND,
    ALU_OR,
    ALU_SLT
};

enum Alu_Op_Class {
    ALU_OP_ADD,
    ALU_OP_SUB,
    ALU_OP_R,
    ALU_OP_I
};

enum Branch_Type {
    BEQ = 0,
    BNE = 1,
    BLT = 4,
    BGE = 5
};

struct Control {
    uint8_t result_src;
    uint8_t alu_src;
    enum Alu_Op alu_control;
    uint8_t reg_write;
    uint8_t mem_write;
    uint8_t branch;
    enum Branch_Type branch_type;
};

struct Control control_generate(struct Decoded_Instr *d);

#endif
