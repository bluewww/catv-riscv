#!/usr/bin/env bash
vsim -c -work work catv_tb +elf=prog/hello_world.hex -do 'run -all;quit'
