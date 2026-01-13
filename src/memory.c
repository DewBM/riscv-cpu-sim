#include "../include/memory.h"


void mem_init(struct Memory *mem, uint32_t size) {
    mem->size = size;
    mem->data = calloc(size, 1);
}

uint32_t mem_read(struct Memory *mem, uint32_t address) {
    uint32_t eff_address = address % mem->size; // address space is circular

    return *(uint32_t *)(mem->data + eff_address);
/*
    return (uint32_t)mem->data[eff_address]
	| (uint32_t)mem->data[eff_address+1] << 8
	| (uint32_t)mem->data[eff_address+2] << 16
	| (uint32_t)mem->data[eff_address+3] << 24;
*/
}

void mem_write(struct Memory *mem, uint32_t address, uint32_t write_data, uint8_t write_enable) {
    if (write_enable == 0) {
	fprintf(stderr, "Cannot write: write_enable is not asserted\n");
	exit(EXIT_FAILURE);
    }
    uint32_t eff_address = address % mem->size;

    *(uint32_t *)(mem->data + eff_address) = write_data;

//    mem->data[eff_address] = (uint8_t)(write_data);
//    mem->data[eff_address+1] = (uint8_t)(write_data >> 8);
//    mem->data[eff_address+2] = (uint8_t)(write_data >> 16);
//    mem->data[eff_address+3] = (uint8_t)(write_data >> 24);
}
