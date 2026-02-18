#ifndef PIPELINE_H
#define PIPELINE_H

#include <stdint.h>

#include "control.h"

// pipeline registers for the IF_ID stage
struct IF_ID {
    uint32_t pc;	// incremented pc address
    uint32_t inst;	// fetched instruction
};

// pipeline registers for the ID_EX stage
struct ID_EX {
    struct Control control;
    uint32_t rs1Val;
    uint32_t pcPlus4;
    uint32_t rs2Val;
    uint32_t imm;
    uint32_t rd;
};

// pipeline registers for the EX_MEM stage
struct EX_MEM {
    struct Control control;
    uint32_t alu_res;
    uint32_t rd;
    uint32_t rs2Val;
    uint32_t pcPlus4;
};

struct MEM_WB {
    struct Control control;
    uint32_t read_data;
    uint32_t alu_res;
    uint32_t pcPlus4;
    uint32_t rd;
};

struct Pipeline {
    struct IF_ID if_id;
    struct ID_EX id_ex;
    struct EX_MEM ex_mem;
    struct MEM_WB mem_wb;
};


#endif
