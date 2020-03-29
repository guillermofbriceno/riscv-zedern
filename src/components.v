`include "defs.v"

// CPU components
module RegisterFile(rs1_addr, rs2_addr, rs1_out, rs2_out, rd_addr, rd_data, write, clk);
        input [4:0] rs1_addr, rs2_addr, rd_addr;
        input [31:0]rd_data;
        input write;
        input clk;
        output [31:0] rs1_out, rs2_out;

        wire [31:0] reg5test;

        reg [31:0] registers [31:0];

        assign rs1_out = registers[rs1_addr];
        assign rs2_out = registers[rs2_addr];
        assign reg5test = registers[5];

        integer i;
        initial begin
                $dumpfile("cpu_test.vcd");
                for (i = 0; i < 32; i = i + 1) begin
                        registers[i] <= 32'b0; 
                        $dumpvars(0, registers[i]);
                end
        end

        always @ (posedge clk) begin
                if (rd_addr != 5'b0 && write) begin
                        registers[rd_addr] <= rd_data;
                end
        end
endmodule

module Alu(in1, in2, out, func, alu_branch);
        input [31:0] in1, in2;
        input [9:0] func;
        output reg [31:0] out;
        output reg [2:0] alu_branch;
        wire  [31:0] sub;

        assign sub = in1 - in2;

        always @(*) begin
                case(func)
                        10'b0000000_000: out = in1 +   in2;
                        10'b0100000_000: out = sub;
                        10'b0000000_001: out = in1 <<  in2[4:0];
                        10'b0000000_100: out = in1 ^   in2;
                        10'b0000000_101: out = in1 >>  in2[4:0];
                        10'b0100000_101: out = in1 >>> in2[4:0];
                        10'b0000000_110: out = in1 |   in2;
                        10'b0000000_111: out = in1 &   in2;
                endcase

                alu_branch[`EQ_IDX]  = in1 == in2;
                alu_branch[`LTS_IDX] = (in1[31] != in2[31]) ? in2[31] : sub[31];
                alu_branch[`LTU_IDX] = in1 <  in2;
        end


endmodule

// System Components

module MemoryUnit #(parameter bits_data = 32, bits_addr = 32, entries=1024) (
        input clk,
        input [bits_addr - 1:0] address,
        input [bits_data - 1:0] data_in,
        input write,
        output wire [bits_data - 1:0] data_out
        );

        //reg [bits_data - 1:0] memory [0:entries - 1];
        reg [7:0] memory [0:entries - 1];

        initial begin
                $readmemh("/home/guillermo/programming/riscv-zedern/scripts/image.hex", memory);
        end

        always @(posedge clk) begin
                if (write) begin
                        memory[address]   <= data_in[31:24];
                        memory[address+1] <= data_in[23:16];
                        memory[address+2] <= data_in[15:08];
                        memory[address+3] <= data_in[07:00];
                end
        end

        assign data_out = {memory[address], memory[address+1], memory[address+2], memory[address+3]};
endmodule

module clock_gen #(parameter clock_tap = 21)(in_clk, out_clk);
        input in_clk;
        output out_clk;

        reg[clock_tap:0] counter = {clock_tap{1'b0}};
        assign out_clk = counter[clock_tap];

        always @ (posedge in_clk) begin
                counter = counter + 1;
        end
endmodule
