# SPDX-License-Identifier: Apache-2.0
# Author: Robert Balas (balasr@iis.ee.ethz.ch)

RISCV           = $(HOME)/.riscv
CC		= $(RISCV)/bin/riscv32-unknown-elf-gcc
CFLAGS		= -march=rv32i -Os -g
LDFLAGS         = -nostdlib -static -T prog/link.ld
LDLIBS		= -lc -lm -lgcc

OBJCOPY         = $(RISCV)/bin/riscv32-unknown-elf-objcopy

all: prog/hello_world.hex

prog/hello_world: prog/hello_world.c prog/crt0.S prog/syscalls.c prog/vectors.S
	$(CC) $(CFLAGS) $(CPPFLAGS) $(LDFLAGS) $^ $(LDLIBS) -o $@

%.hex: %
	$(OBJCOPY) -O verilog $< $@
# %.o: %.c
#	$(CC) $(CFLAGS) $(CPPFLAGS) $(TARGET_ARCH) -c -o $@ $<

# %: %.o
#	$(CC) $(LDFLAGS) $(TARGET_ARCH) $^ $(LOADLIBES) $(LDLIBS) -o $@

# %: %.c
#	$(CC) $(CFLAGS) $(CPPFLAGS) $(LDFLAGS) $(TARGET_ARCH) $^ $(LOADLIBES) $(LDLIBS) -o $@

.PHONY: clean
clean:
	rm -f prog/hello_world prog/hello_world.hex
