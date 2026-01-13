#include "../include/cpu.h"


void load_program(struct Memory *mem, const char *filename) {
    FILE *f = fopen(filename, "rb");

    if (f == NULL) {
        perror("Error opening program file");
        exit(EXIT_FAILURE); // Stop the program if the file can't be found/opened
    }

    fread(mem->data, 1, mem->size, f);
    fclose(f);
}

void reg_dump(struct Registers *reg) {
    for (int i=0; i<32; i++) {
	printf("x%d: %d\n", i, reg->regs[i]);
    }
}


int main(void) {
    struct CPU cpu = { .halt = false };

    cpu_init(&cpu);

    uint32_t instr[] = {0x00A00093, 0x01400113, 0x002081B3, 0x10000213, 0x00322023, 0x00000293, 0x00022283, 0x00528313, 0x00100073};
    for (int i=0; i<9; i++){
	mem_write(cpu.mem, i*4, instr[i], 1);
    }

//    mem_write(cpu.mem, 0, 0x00500093, 1);
//    mem_write(cpu.mem, 4, 0x00100073, 1);

//    load_program(cpu.mem, "tests/bins/test1.bin");

    while (!cpu.halt) {
	cpu_cycle(&cpu);
    }

    reg_dump(cpu.reg);

    return 0;
}
