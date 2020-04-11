`include "cpu.v"
`include "components.v"
`timescale 1ns / 1ns

module cpu_tb();
        
        reg clk = 0;
        wire write;
        integer i = 0;
        wire [31:0] instruction;
        reg  [31:0] data_in;
        wire [31:0] data_out;
        wire [ 9:0] instruction_address;
        wire [ 9:0] data_address;
        wire [3:0 ] width;
        wire [31:0] inst_mem_data;
        wire [31:0] data_mem_data;
        wire [7:0]  leds;


        RV32I_CPU CPU(
                .clk(clk), 
                .instruction(instruction),
                .data_in(data_mem_data),
                .data_out(data_out),
                .width(width),
                .write_mem(write),
                .instruction_address(instruction_address),
                .data_address(data_address)
        );

        InstructionMemory BOOTROM(
                .clk(clk),
                .address_p1(instruction_address),
                .address_p2(data_address),
                .data_out_p1(instruction),
                .data_out_p2(inst_mem_data)
        );

        DataMemory DATAMEM(
                .clk(clk),
                .address(data_address),
                .data_in(data_out),
                .width(width),
                .write(write),
                .data_out(data_mem_data)
        );

        always @(*) begin
                case (data_address[9])
                        1'b0: data_in = inst_mem_data;
                        1'b1: data_in = data_mem_data;
                endcase
        end

        GPOPeriph LEDS(
                .clk(clk),
                .address(data_address),
                .data(data_out[7:0]),
                .write(write),
                .out(leds)
        );


        initial begin
                $dumpfile("cpu_test.vcd");
                $dumpvars(0, CPU);
                $dumpvars(0, BOOTROM);
                $dumpvars(0, DATAMEM);
                $dumpvars(0, LEDS);
                #41.665;
                //$display("%d",instruction_address);
                for (i=0; i < 1000; i=i+1) begin
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
