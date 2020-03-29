PROJ=cpu
BUILD=./build

INC=src
FILES=$(INC)/computer.v
TOP=computer
TEST=src/cpu_tb.v

.PHONY: all check clean burn

all:
	mkdir -p $(BUILD)
	yosys -p 'synth_ice40 -top $(TOP) -json $(BUILD)/$(PROJ).json' $(FILES)
	nextpnr-ice40 --hx8k --json $(BUILD)/$(PROJ).json --pcf $(PROJ).pcf --asc $(BUILD)/$(PROJ).asc --pcf-allow-unconstrained
	icepack $(BUILD)/$(PROJ).asc $(BUILD)/$(PROJ).bin
check:
	mkdir -p $(BUILD)
	iverilog -o $(BUILD)/$(PROJ).vvp $(TEST) -I $(INC)
	vvp $(BUILD)/$(PROJ).vvp

burn:
	iceprog $(BUILD)/$(PROJ).bin  

clean:
	rm build/*