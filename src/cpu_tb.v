`include "cpu.v"
`timescale 1ns / 1ns

module cpu_tb();
        
        reg clk = 0;
        wire write;
        integer i = 0;
        wire [31:0] instruction;
        reg  [31:0] data_in;
        wire [31:0] data_out;
        wire [ 9:0] address_instruction;
        wire [ 9:0] address_data;
        wire [3:0 ] width;
        wire [31:0] inst_mem_data;
        wire [31:0] data_mem_data;
        wire [7:0]  leds;


        Cpu CPU(
                .clk(clk), 
                .instruction(instruction),
                .data_in(data_mem_data),
                .data_out(data_out),
                .width(width),
                .write_mem(write),
                .address_instruction(address_instruction),
                .address_data(address_data)
        );

        InstructionMemory BOOTROM(
                .clk(clk),
                .address_p1(address_instruction),
                .address_p2(address_data),
                .data_out_p1(instruction),
                .data_out_p2(inst_mem_data)
        );

        DataMemory DATAMEM(
                .clk(clk),
                .address(address_data),
                .data_in(data_out),
                .width(width),
                .write(write),
                .data_out(data_mem_data)
        );

        always @(*) begin
                case (address_data[9])
                        1'b0: data_in = inst_mem_data;
                        1'b1: data_in = data_mem_data;
                endcase
        end

        GPOPeriph LEDS(
                .clk(clk),
                .address(address_data),
                .data(data_out[7:0]),
                .write(write),
                .out(leds)
        );


        initial begin
                //$dumpfile("cpu_test.vcd");
                //$dumpvars(0, CPU);
                //$dumpvars(0, BOOTROM);
                //$dumpvars(0, DATAMEM);
                //$dumpvars(0, LEDS);
                #41.665;
                //$display("%d",address_instruction);
                for (i=0; i < 1000; i=i+1) begin
                        clk = 1;
                        #41.665;
                        clk = 0;
                        #41.665;
                        //$display("%d",address_instruction);
                end

                //#20

                //$finish;
        end
endmodule
