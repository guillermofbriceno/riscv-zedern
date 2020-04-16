`include "cpu.v"
`include "components.v"
`timescale 1ns / 1ns

module cpu_tb();
        reg clk = 0;
        wire [ 7:0] leds;

        wire write;
        wire [31:0] instruction;
        wire [31:0] data_in;
        wire [31:0] data_out;
        wire [ 9:0] instruction_address;
        wire [ 9:0] data_address;
        wire [3:0 ] width;
        wire [31:0] inst_mem_data;
        wire [31:0] data_mem_data;
        wire [ 0:0] read_inst_enable;
        wire [ 0:0] mem_stall;

        reg [ 1:0] mem_select_bits = 2'b0;

        assign data_in = data_mem_data | inst_mem_data;

        RV32I_CPU CPU(
                .clk(clk), 
                .instruction_in(instruction),
                .data_in(data_in),
                .data_out(data_out),
                .width(width),
                .write_mem(write),
                .instruction_address(instruction_address),
                .data_address(data_address),
                .read_inst_enable(read_inst_enable),
                .mem_stall(mem_stall)
        );

        InstructionMemoryController BOOTROM(
                .clk(clk),
                .address_p1(instruction_address),
                .address_p2(data_address),
                .data_out_inst(instruction),
                .data_out_data(inst_mem_data),
                .stall(mem_stall),
                .select_inst(read_inst_enable),
                .select_data(mem_select_bits[0])
        );

        DataMemory DATAMEM(
                .clk(clk),
                .write(write),
                .address(data_address),
                .data_in(data_out),
                .width(width),
                .select(mem_select_bits[1]),
                .data_out(data_mem_data)
        );

        always @(*) begin
                case (data_address[9])
                        //1'b0: data_in = inst_mem_data;
                        1'b0: mem_select_bits <= 2'b01;
                        1'b1: mem_select_bits <= 2'b10;
                endcase
        end

        GPOPeriph LEDS(
                .clk(clk),
                .address(data_address),
                .data(data_out[7:0]),
                .write(write),
                .out(leds)
        );

        integer i = 0;

        initial begin
                $dumpfile("cpu_test.vcd");
                $dumpvars(0, CPU);
                $dumpvars(0, BOOTROM);
                $dumpvars(0, DATAMEM);
                $dumpvars(0, LEDS);
                $dumpvars(0, cpu_tb);
                #41.665;
                //$display("%d",instruction_address);
                for (i=0; i < 5000; i=i+1) begin
                        clk = 1;
                        #41.665;
                        clk = 0;
                        #41.665;
                        //$display("%d",instruction_address);
                end

                //#20

                //$finish;
        end
endmodule
