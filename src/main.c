#include "cpu.h"


void load_program(struct Memory *mem, const char *filename) {
    FILE *f = fopen(filename, "rb");

    if (f == NULL) {
        perror("Error opening program file");
        exit(EXIT_FAILURE); // Stop the program if the file can't be found/opened
    }

    fread(mem->data + 0x10000, 1, mem->size - 0x10000, f);
    fclose(f);
}

void reg_dump(struct Registers *reg) {
    for (int i=0; i<32; i++) {
	printf("x%d: 0x%08x\n", i, reg->regs[i]);
    }
}


int main(int argc, char *argv[]) {
    if (argc < 2) {
	fprintf(stderr, "Usage: %s <program.bin>\n", argv[0]);
        return EXIT_FAILURE;
    }
    struct CPU cpu = { .halt = false };

    cpu_init(&cpu);

    load_program(cpu.mem, argv[1]);

    while (!cpu.halt) {
	cpu_cycle(&cpu);
    }

    reg_dump(cpu.reg);

    return 0;
}
