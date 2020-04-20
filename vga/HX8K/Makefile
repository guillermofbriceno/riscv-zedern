#ARACHNE_DEVICE = 8k							
#PACKAGE        = ct256							
#
#ICETIME_DEVICE = hx8k							
##
## the -S flag says program the SRAM, not flash				
#PROG_BIN     = iceprog -S						
#
#include ../std.mk


all:
	mkdir -p ./build
	yosys -p 'synth_ice40 -top top -json ./build/vga.json' top.v
	nextpnr-ice40 --hx8k --package ct256 --json ./build/vga.json --pcf pins.pcf --asc ./build/vga.asc

burn:
	icepack ./build/vga.asc ./build/vga.bin
	iceprog ./build/vga.bin


