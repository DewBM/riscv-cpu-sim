#include "../include/control.h"

static void alu_decoder(struct Control *control, uint8_t alu_op, uint8_t funct3, uint8_t funct) {
    switch (alu_op) {
	case 0:
	    control->alu_control = ADD;
	    break;
	case 1:
	    // branch
	    break;
	case 2:
	    switch (funct3) {
		case 0:
		    if (funct == 3) {
			control->alu_control = SUB;
		    }
		    else {
			control->alu_control = ADD;
		    }
		    break;
		case 2:
		    control->alu_control = STL;
		    break;
		case 6:
		    control->alu_control = OR;
		    break;
		case 7:
		    control->alu_control = AND;
		    break;
	    }
    }
}


struct Control control_generate(struct Decoded_Instr *d) {
    struct Control control;

    uint32_t alu_op;

    // Main Decoder
    switch (d->mapping.name) {
	case LOAD:
	    control.reg_write = 0x01;
	    control.alu_src = 0x01;
	    control.mem_write = 0x00;
	    control.result_src = 0x01;
	    alu_op = 0x00;
	    break;

	case STORE:
	    control.reg_write = 0x00;
	    control.alu_src = 0x01;
	    control.mem_write = 0x01;
	    alu_op = 0x00;
	    break;

	case OP:
	    control.reg_write = 0x01;
	    control.alu_src = 0x00;
	    control.mem_write = 0x00;
	    control.result_src = 0x00;
	    alu_op = 0x02;
	    break;

	case OP_IMM:
	    control.reg_write = 0x01;
	    control.alu_src = 0x01;
	    control.mem_write = 0x00;
	    control.result_src = 0x00;
	    alu_op = 0x02;
	    break;
	default:
	    fprintf(stderr, "Fatal error: Unhandled or invalid opcode name %d in control unit.\n", d->mapping.name);
	    exit(EXIT_FAILURE);
    }

    uint8_t funct = ((d->funct7 >> 4) & 0x01) | ((d->mapping.bits >> 4) & 0x01);
    alu_decoder(&control, alu_op, d->funct3, funct);

    return control;
};
