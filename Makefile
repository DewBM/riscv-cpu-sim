CC      = gcc
CFLAGS  = -Wall -Wextra -std=c11 -Iinclude -g
LDFLAGS =

AS      = riscv32-unknown-elf-as
LD      = riscv32-unknown-elf-ld
OBJCOPY = riscv32-unknown-elf-objcopy
ASFLAGS = -march=rv32i -mabi=ilp32

SRC = \
      src/main.c \
      src/cpu.c \
      src/registers.c \
      src/memory.c \
      src/decode.c \
      src/control.c \
      src/stages/inst_fetch.c \
      src/stages/inst_decode.c \
      src/stages/inst_execute.c \
      src/stages/mem_stage.c \
      src/stages/wb_stage.c \

OBJ    = $(patsubst src/%, build/obj/%, $(SRC:.c=.o))
TARGET = build/simulator

TEST_SRCS = $(wildcard tests/asm/*.s)
TEST_NAMES = $(patsubst tests/asm/%.s, %, $(TEST_SRCS))
TEST_ELFS  = $(addprefix tests/elfs/, $(addsuffix .elf, $(TEST_NAMES)))
TEST_BINS  = $(addprefix tests/bins/, $(addsuffix .bin, $(TEST_NAMES)))

# ── Simulator ─────────────────────────────────────────────────────────────────

.PHONY: all clean test

all: $(TARGET)

$(TARGET): $(OBJ) | build
	$(CC) $(OBJ) -o $@ $(LDFLAGS)

build/obj/%.o: src/%.c | build
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c $< -o $@

build:
	mkdir -p build/obj/stages

# ── Test binaries ─────────────────────────────────────────────────────────────

tests/elfs/%.elf: tests/asm/%.s tests/asm/link.ld
	@mkdir -p tests/elfs
	$(AS) $(ASFLAGS) -o /tmp/$*_rv32i.o $<
	$(LD) -T tests/asm/link.ld -o $@ /tmp/$*_rv32i.o

tests/bins/%.bin: tests/elfs/%.elf
	@mkdir -p tests/bins
	$(OBJCOPY) -O binary --only-section=.text $< $@

build-tests: $(TEST_ELFS) $(TEST_BINS)

# ── Run tests ─────────────────────────────────────────────────────────────────

test: $(TARGET) build-tests
	python3 tests/run_tests.py

# ── Clean ─────────────────────────────────────────────────────────────────────

clean:
	rm -rf build/ tests/elfs/ tests/bins/ /tmp/*_rv32i.o
