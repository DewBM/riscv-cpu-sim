#ifndef MEMORY_H
#define MEMORY_H

#include <stdint.h>
#include <stdlib.h>
#include <stdbool.h>
#include <stdio.h>


struct Memory {
    uint32_t size;
    uint8_t *data;
};

void mem_init(struct Memory *mem, uint32_t size);

uint32_t mem_read(struct Memory *mem, uint32_t address);

void mem_write(struct Memory *mem, uint32_t address, uint32_t write_data, uint8_t write_enable);

#endif
