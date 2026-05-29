#include "decode.h"
#include "utils.h"
#include <stdio.h>
#include <stdlib.h>

const struct Instr_Mapping opcode_table[] = {
    {LOAD, I, 0x03},
    {STORE, S, 0x23},
    {OP, R, 0x33},
    {OP_IMM, I, 0x13},
    {BRANCH, B, 0x63},
    {JALR, I, 0x67},
    {JAL, J, 0x6F},
    {LUI, U, 0x37},
    {AUIPC, U, 0x17},
    {OP_INVALID, -1, -1}
};


struct Instr_Mapping decode_type(uint32_t instr) {
    uint8_t opcode = instr & 0x7F;

    for(size_t i=0; i < sizeof(opcode_table)/sizeof(opcode_table[0]); i++) {
	if (opcode_table[i].bits == opcode) {
	    return opcode_table[i];
	}
    }
    return opcode_table[OP_INVALID];
}


struct Decoded_Instr decode(uint32_t instr) {
    struct Instr_Mapping instr_mapping = decode_type(instr);

    if (instr_mapping.name == OP_INVALID) {
	fprintf(stderr, "Couldn't decode instruction: Invalid opcode\n");
	exit(EXIT_FAILURE);
    }

    struct Decoded_Instr d;
    d.mapping = instr_mapping;
    d.rs1 = (instr >> 15) & 0x1F;

    switch(instr_mapping.type) {
	case R:
	    d.funct3 = (instr >> 12) & 0x7;
	    d.rs2 = (instr >> 20) & 0x1F;
	    d.rd = (instr >> 7) & 0x1F;
	    d.funct7 = (instr >> 25) & 0x7F;
	    break;
	case I: {
	    d.funct3 = (instr >> 12) & 0x7;
	    d.rd = (instr >> 7) & 0x1F;

	    if (instr_mapping.name == OP_IMM && (d.funct3 == 0x1 || d.funct3 == 0x5)) {
		d.imm = (instr >> 20) & 0x1F;
		d.funct7 = (instr >> 25) & 0x7F;
	    }
	    else {
		uint32_t imm_temp = (instr >> 20) & 0xFFF;
		d.imm = sign_extend(imm_temp, 12);
	    }

	    break;
	}
	case S: {
	    d.funct3 = (instr >> 12) & 0x7;
	    d.rs2 = (instr >> 20) & 0x1F;
	    uint32_t imm_l = (instr >> 7) & 0x1F;
	    uint32_t imm_h = (instr >> 25) & 0x7F;
	    d.imm = sign_extend((imm_h << 5) | imm_l, 12);
	    break;
	}
	case B: {
	    d.funct3 = (instr >> 12) & 0x7;
	    d.rs2 = (instr >> 20) & 0x1F;
	    uint32_t imm_11 = (instr >> 7) & 0x1;
	    uint32_t imm_4_1 = (instr >> 8) & 0xF;
	    uint32_t imm_10_5 = (instr >> 25) & 0x3F;
	    uint32_t imm_12 = (instr >> 31) & 0x1;
	    uint32_t imm_temp = (imm_12 << 11)
		| (imm_11 << 10)
		| (imm_10_5 << 4)
		| imm_4_1;
	    d.imm = sign_extend(imm_temp << 1, 13);
	    break;
	}
	case J: {
	    d.rd = (instr >> 7) & 0x1F;
	    uint32_t imm_20 = (instr >> 31) & 0x1;
	    uint32_t imm_19_12 = (instr >> 12) & 0xFF;
	    uint32_t imm_11 = (instr >> 20) & 0x1;
	    uint32_t imm_10_1 = (instr >> 21) & 0x3FF;
	    uint32_t imm_temp = (imm_20 << 19) 
		| (imm_19_12 << 11) 
		| (imm_11 << 10)
		| imm_10_1;
	    d.imm = sign_extend(imm_temp << 1, 21);
	    break;
	}
	case U: {
	    d.rd = (instr >> 7) & 0x1F;
	    d.rs1 = 0;	// set rs1 as x0 explicitly to pass imm through alu without any alterations.
	    d.imm = (instr & 0xFFFFF000);
	    break;
	}
    }

    return d;
}


