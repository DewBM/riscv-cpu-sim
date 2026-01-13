#include "../include/decode.h"

const struct Instr_Mapping opcode_table[] = {
    {LOAD, I, 0x03},
    {STORE, S, 0x23},
    {OP, R, 0x33},
    {OP_IMM, I, 0x13},
    {BRANCH, B, 0x63},
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


static uint32_t sign_extend(uint32_t val, int nBits) {
    uint32_t mask = 1U << (nBits -1);
    return (val ^ mask) - mask;
}


struct Decoded_Instr decode(uint32_t instr) {
    struct Instr_Mapping instr_mapping = decode_type(instr);

    if (instr_mapping.name == OP_INVALID) {
	fprintf(stderr, "Couldn't decode instruction: Invalid opcode\n");
	exit(EXIT_FAILURE);
    }

    struct Decoded_Instr d;
    d.mapping = instr_mapping;
    d.funct3 = (instr >> 12) & 0x7;
    d.rs1 = (instr >> 15) & 0x1F;

    switch(instr_mapping.type) {
	case R:
	    d.rs2 = (instr >> 20) & 0x1F;
	    d.rd = (instr >> 7) & 0x1F;
	    d.funct7 = (instr >> 25) & 0x7F;
	    break;
	case I: {
	    d.rd = (instr >> 7) & 0x1F;
	    uint32_t imm_temp = (instr >> 20) & 0xFFF;
	    d.imm = sign_extend(imm_temp, 12);
	    break;
	}
	case S: {
	    d.rs2 = (instr >> 20) & 0x1F;
	    uint32_t imm_l = (instr >> 7) & 0x1F;
	    uint32_t imm_h = (instr >> 25) & 0x7F;
	    d.imm = sign_extend((imm_h << 5) | imm_l, 12);
	    break;
	}
	case B: {
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
    }

    return d;
}


