#ifndef MEMORY_H
#define MEMORY_H

#include "control.h"
#include <stdint.h>
#include <stdbool.h>


struct Memory {
    uint32_t size;
    uint8_t *data;
};

void mem_init(struct Memory *mem, uint32_t size);

uint32_t mem_read32(struct Memory *mem, uint32_t address);
uint16_t mem_read16(struct Memory *mem, uint32_t address);
uint8_t mem_read8(struct Memory *mem, uint32_t address);

void mem_write(struct Memory *mem, uint32_t address, uint32_t write_data, enum LS_Type size, uint8_t write_enable);

#endif
