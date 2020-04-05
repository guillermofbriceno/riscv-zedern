`include "defs.v"

// CPU components
module RegisterFile(rs1_addr, rs2_addr, rs1_out, rs2_out, rd_addr, rd_data, write, clk);
        input [4:0] rs1_addr, rs2_addr, rd_addr;
        input [31:0]rd_data;
        input write;
        input clk;
        output wire [31:0] rs1_out, rs2_out;

        reg [31:0] registers [31:0];

        assign rs1_out = registers[rs1_addr];
        assign rs2_out = registers[rs2_addr];

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

        //always @ (posedge clk) begin
        //        rs1_out <= registers[rs1_addr];
        //        rs2_out <= registers[rs2_addr];
        //end
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
                        10'b0000001_000: out = in1 *   in2;
                        default:         out = 32'b0;
                endcase

                alu_branch[`EQ_IDX]  <= in1 == in2;
                alu_branch[`LTS_IDX] <= (in1[31] != in2[31]) ? in2[31] : sub[31];
                alu_branch[`LTU_IDX] <= in1 <  in2;
        end


endmodule

module InstructionMemory #(parameter bits_data = 32, bits_addr = 10, entries=1024) (
        input clk,
        input [bits_addr - 1:0] address_p1,
        input [bits_addr - 1:0] address_p2,
        output reg [bits_data - 1:0] data_out_p1,
        output reg [bits_data - 1:0] data_out_p2
        );

        reg [7:0] memory [0:entries - 1];

        initial begin
                $readmemh("/home/guillermo/programming/riscv-zedern/scripts/c_image.hex", memory);
        end

        always @(posedge clk) begin
                data_out_p1 <= {memory[address_p1+3], memory[address_p1+2], memory[address_p1+1], memory[address_p1]};
                data_out_p2 <= {memory[address_p2+3], memory[address_p2+2], memory[address_p2+1], memory[address_p2]};
        end
endmodule

module DataMemory #(parameter bits_data = 32, bits_addr = 32, entries=1024) (
        input clk,
        input [bits_addr - 1:0] address,
        input [bits_data - 1:0] data_in,
        input [3:0] width,
        input write,
        output reg [bits_data - 1:0] data_out
        );

        reg [31:0] memory [0:entries - 1];
        integer i;

        initial begin
                $readmemh("/home/guillermo/programming/riscv-zedern/scripts/empty.hex", memory);
                for(i=0; i < 1024; i=i+1) begin
                        $dumpvars(0, memory[i]);
                end
        end

        always @(posedge clk) begin
                if (write) begin
                        if (width[3]) begin
                                memory[address[31:2]][7:0] <= data_in[31:24];
                        end
                        if (width[2]) begin
                                memory[address[31:2]][15:8] <= data_in[23:16];
                        end
                        if (width[1]) begin
                                memory[address[31:2]][23:16] <= data_in[15:8];
                        end
                        if (width[0]) begin
                                memory[address[31:2]][31:24] <= data_in[7:0];
                        end

                end
        end

        always @(negedge clk) begin
                data_out <= {memory[address[31:2]][7:0], memory[address[31:2]][15:8], memory[address[31:2]][23:16], memory[address[31:2]][31:24]};
        end
endmodule

module GPOPeriph (address, data, out, clk, write);
        input [31:0] address;
        input [ 7:0] data;
        input        clk;
        input        write;
        output [7:0] out;

        reg [7:0] mem = 8'b0;
        
        always @ (posedge clk) begin
                if (address == 32'h50 & write) begin
                        mem <= data;
                end
        end
        assign out = mem;

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
