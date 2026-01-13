#include "../include/control.h"

static void alu_decoder(struct Control *control, uint8_t funct3, uint8_t funct7, enum Alu_Op_Class op_class) {
    switch (op_class) {
	case ALU_OP_ADD:
	    control->alu_control = ALU_ADD;
	    break;
	case ALU_OP_SUB:
	    control->alu_control = ALU_SUB; // branch
	    switch (funct3) {
		case 0: control->branch_type = BEQ; break;
		case 1: control->branch_type = BNE; break;
		case 4: control->branch_type = BLT; break;
		case 5: control->branch_type = BGE; break;
		default: 
		    fprintf(stderr, "Error: Invalid branch type value: %d\n", funct3);
		    break;
	    }
	    break;
	case ALU_OP_R:
	    switch (funct3) {
		case 0x0:
		    control->alu_control = funct7 == 0x20 ? ALU_SUB : ALU_ADD;
		    break;
		case 0x7:
		    control->alu_control = ALU_AND;
		    break;
		case 0x6:
		    control->alu_control = ALU_OR;
		    break;
	    }
	    break;
	case ALU_OP_I:
	    switch (funct3) {
		case 0x0:
		    control->alu_control = ALU_ADD;
		    break;
		case 0x7:
		    control->alu_control = ALU_AND;
		    break;
		case 0x6:
		    control->alu_control = ALU_OR;
		    break;
	    }
	    break;
    }
}


struct Control control_generate(struct Decoded_Instr *d) {
    struct Control control;

    //uint32_t alu_op;
    enum Alu_Op_Class op_class;

    // Main Decoder
    switch (d->mapping.name) {
	case LOAD:
	    control.reg_write = 0x01;
	    control.alu_src = 0x01;
	    control.mem_write = 0x00;
	    control.result_src = 0x01;
	    control.branch = 0;
	    //alu_op = 0x00;
	    op_class = ALU_OP_ADD;
	    break;

	case STORE:
	    control.reg_write = 0x00;
	    control.alu_src = 0x01;
	    control.mem_write = 0x01;
	    control.branch = 0;
	    //alu_op = 0x00;
	    op_class = ALU_OP_ADD;
	    break;

	case OP:
	    control.reg_write = 0x01;
	    control.alu_src = 0x00;
	    control.mem_write = 0x00;
	    control.result_src = 0x00;
	    control.branch = 0;
	    //alu_op = 0x02;
	    op_class = ALU_OP_R;
	    break;

	case OP_IMM:
	    control.reg_write = 0x01;
	    control.alu_src = 0x01;
	    control.mem_write = 0x00;
	    control.result_src = 0x00;
	    control.branch = 0;
	    //alu_op = 0x02;
	    op_class = ALU_OP_I;
	    break;
	case BRANCH:
	    control.reg_write = 0;
	    control.alu_src = 0;
	    control.mem_write = 0;
	    control.branch = 1;
	    //alu_op = 1;
	    op_class = ALU_OP_SUB;
	    break;
	default:
	    fprintf(stderr, "Fatal error: Unhandled or invalid opcode name %d in control unit.\n", d->mapping.name);
	    exit(EXIT_FAILURE);
    }

    uint8_t funct = ((d->funct7 >> 4) & 0x02) | ((d->mapping.bits >> 4) & 0x01);
    alu_decoder(&control, d->funct3, d->funct7, op_class);

    return control;
};
