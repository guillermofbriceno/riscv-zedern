#$(CC) $(CFLAGS) -T$(LINKSCRIPT) $(INC) -o $(BUILD)/main $(FILE) -e ResetHandler

PROJECT=main

SRCS=$(wildcard src/*.c) \
     $(wildcard libs/*.c)
OBJ=obj/
OBJS = $(addprefix $(OBJ),$(notdir $(SRCS:.c=.o)))

INC=-Iinc

RISCVPRE=/home/guillermo/.local/bin/riscv

LDSCRIPT=link.ld
#CC=riscv32-unknown-elf-gcc
CC=riscv32-unknown-elf-gcc -c
CFLAGS=-O2 -march=rv32i -mabi=ilp32 -nostdlib -lgcc
LD=riscv32-unknown-elf-gcc
LDFLAGS=-march=rv32i -Wl,-T$(LDSCRIPT) -ffreestanding -nostdlib -Wl,-eResetHandler -Wl,-lgcc -Wl,-L/home/guillermo/.local/bin/riscv/lib/gcc/riscv32-unknown-elf/9.2.0/rv32i/ilp32/libgcc.a
OBJCOPY=riscv32-unknown-elf-objcopy
OBJDUMP=riscv32-unknown-elf-objdump

MKDIR=@mkdir -p $(@D)

.PHONY: all clean

all: bin/$(PROJECT).bin

$(OBJ)%.o: src/%.c
	$(MKDIR)              
	$(CC) -o $@ $^ $(INC) $(CFLAGS)

$(OBJ)%.o: libs/%.c
	$(MKDIR)              
	$(CC) -o $@ $^ $(INC) $(CFLAGS)

bin/$(PROJECT).elf: $(OBJS)      ##contains debug symbols for GNU GDB
	$(MKDIR)              
	$(LD) -o $@ $^ $(LDFLAGS)

bin/$(PROJECT).bin: bin/$(PROJECT).elf    #debug symbols for GNU GDB stripped by objcopy,finished binary ready for flashing
	$(OBJCOPY) -O binary $< $@

read:
	$(OBJDUMP) -d bin/main.elf
	./read.py

hexdump:
	elf2hex 1 1024 bin/main.elf > ~/programming/riscv-zedern/scripts/c_image.hex

clean:
	rm -rf bin
	rm -rf obj

