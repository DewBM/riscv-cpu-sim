#include "utils.h"

uint32_t sign_extend(uint32_t val, int nBits) {
    uint32_t mask = 1U << (nBits -1);
    return (val ^ mask) - mask;
}
