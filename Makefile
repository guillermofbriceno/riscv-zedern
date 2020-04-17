PROJ=cpu
FINAL=final
BUILD=./build

INC=src
FILES=$(INC)/computer.v
TOP=computer
TEST=src/cpu_tb.v

.PHONY: all check clean burn

all:
	mkdir -p $(BUILD)
	#yosys -p 'synth_ice40 -top $(TOP) -json $(BUILD)/$(PROJ).json -noflatten' $(FILES)
	yosys -p 'synth_ice40 -top $(TOP) -json $(BUILD)/$(PROJ).json' $(FILES)
	nextpnr-ice40 --hx8k --package ct256 --json $(BUILD)/$(PROJ).json --pcf $(PROJ).pcf --asc $(BUILD)/$(PROJ).asc
check:
	mkdir -p $(BUILD)
	iverilog -o $(BUILD)/$(PROJ).vvp $(TEST) -I $(INC)
	vvp $(BUILD)/$(PROJ).vvp

burn:
	icebram scripts/datafile_syn.hex scripts/c_image.hex < $(BUILD)/$(PROJ).asc > build/$(FINAL).asc
	#icepack $(BUILD)/$(PROJ).asc $(BUILD)/$(PROJ).bin
	icepack $(BUILD)/$(FINAL).asc $(BUILD)/$(PROJ).bin
	iceprog $(BUILD)/$(PROJ).bin  

gui:
	nextpnr-ice40 --hx8k --json $(BUILD)/$(PROJ).json --pcf $(PROJ).pcf --asc $(BUILD)/$(PROJ).asc --gui

yo:
	yosys -p 'synth_ice40 -top $(TOP) -json $(BUILD)/$(PROJ).json' $(FILES)

pnr:
	nextpnr-ice40 --hx8k --package ct256 --json $(BUILD)/$(PROJ).json --pcf $(PROJ).pcf --asc $(BUILD)/$(PROJ).asc

clean:
	rm build/*
