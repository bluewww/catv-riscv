# SPDX-License-Identifier: Apache-2.0
# Author: Robert Balas (balasr@iis.ee.ethz.ch)

RISCV           = $(HOME)/.riscv
CC		= $(RISCV)/bin/riscv32-unknown-elf-gcc
CFLAGS		= -march=rv32i -mabi=ilp32 -Os -g
LDFLAGS         = -nostdlib -static -T prog/link.ld
LDLIBS		= -lc -lm -lgcc

OBJCOPY         = $(RISCV)/bin/riscv32-unknown-elf-objcopy

ifeq ($(VERILATOR_ROOT),)
VERILATOR = verilator
else
export VERILATOR_ROOT
VERILATOR = $(VERILATOR_ROOT)/bin/verilator
endif

all: prog/hello_world.hex

prog/hello_world: prog/hello_world.c prog/crt0.S prog/syscalls.c prog/vectors.S
	$(CC) $(CFLAGS) $(CPPFLAGS) $(LDFLAGS) $^ $(LDLIBS) -o $@

%.hex: %
	$(OBJCOPY) -O verilog $< $@

.PHONY: verilate
verilate:
	$(VERILATOR) --cc --exe --build -j \
	--Wno-fatal --x-initial-edge --timescale 1ps \
	../src/catv_riscv.sv  catv_tb_veri.sv  catv_tb_veri.cpp \
	$(VERI_FLAGS)
	cp obj_dir/Vcatv_riscv catv_riscv

.PHONY: run
run: prog/hello_world.hex
	./catv_riscv +elf=$^

.PHONY: clean
clean:
	$(RM) prog/hello_world prog/hello_world.hex
	$(RM) -r obj_dir
