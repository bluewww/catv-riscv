#!/usr/bin/env bash
vlog -64 +acc -pedanticerrors catv_tb.sv
vlog -64 +acc -pedanticerrors ../src/catv_riscv.sv
# vsim -c -work work -elab elab -pedanticerrors catv_tb +elf=prog/hello_world.hex
