#ifndef DECODE_H
#define DECODE_H

#include <stdint.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>

enum Opcode {
    LOAD,
    STORE,
    OP,
    OP_IMM,
    OP_INVALID,
    BRANCH
};


enum Instr_Type { R, I, S, B };

struct Instr_Mapping {
    enum Opcode name;
    enum Instr_Type type;
    uint8_t bits;
};



struct Decoded_Instr {
    struct Instr_Mapping mapping;
    uint32_t rs1;
    uint32_t rs2;
    uint32_t rd;
    uint32_t imm;
    uint8_t funct3;
    uint8_t funct7;
};

struct Decoded_Instr decode(uint32_t instr);

#endif
