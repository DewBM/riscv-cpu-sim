CC      = gcc
CFLAGS  = -Wall -Wextra -std=c11 -Iinclude -g
LDFLAGS =

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

OBJ = $(SRC:.c=.o)

TARGET = riscv-sim

all: $(TARGET)

$(TARGET): $(OBJ)
	$(CC) $(OBJ) -o $@ $(LDFLAGS)

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(OBJ) $(TARGET)
