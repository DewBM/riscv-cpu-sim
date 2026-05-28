#include "memory.h"
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>


void mem_init(struct Memory *mem, uint32_t size) {
    mem->size = size;
    mem->data = calloc(size, 1);
}

static uint32_t mem_read(struct Memory *mem, uint32_t address, int size) {
    uint32_t eff_address = address % mem->size;

    switch (size) {
	case 1: return *(uint8_t *)(mem->data + eff_address);
	case 2: return *(uint16_t *)(mem->data + eff_address);
	case 4: return *(uint32_t *)(mem->data + eff_address);
	default: 
	    fprintf(stderr, "Error: Memory address misalignment\n");
	    exit(EXIT_FAILURE);
    }
}

uint32_t mem_read32(struct Memory *mem, uint32_t address) {
    return mem_read(mem, address, 4);
}

uint16_t mem_read16(struct Memory *mem, uint32_t address) {
    return (uint16_t) mem_read(mem, address, 2);
}


uint8_t mem_read8(struct Memory *mem, uint32_t address) {
    return (uint8_t) mem_read(mem, address, 1);
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
