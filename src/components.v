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

module Alu(in1, in2, out, func);
        input [31:0] in1, in2;
        input [9:0] func;
        output reg [31:0] out;


        always @(*) begin
                case(func)
                        10'b0000000_000: out = in1 +   in2;
                        10'b0100000_000: out = in1 -   in2;
                        10'b0000000_001: out = in1 <<  in2[4:0];
                        10'b0000000_100: out = in1 ^   in2;
                        10'b0000000_101: out = in1 >>  in2[4:0];
                        10'b0100000_101: out = in1 >>> in2[4:0];
                        10'b0000000_110: out = in1 |   in2;
                        10'b0000000_111: out = in1 &   in2;
                endcase
        end

endmodule

// System Components

module MemoryUnit #(parameter bits_data = 32, bits_addr = 32, entries=1024) (
        input clk,
        input [bits_addr - 1:0] address,
        input [bits_data - 1:0] data_in,
        input write,
        output reg [bits_data - 1:0] data_out
        );

        reg [bits_data - 1:0] memory [0:entries - 1];

        initial begin
                memory[0] = 32'b00000010000000000000_10000_0110111; //LUI x16,0x2000
                memory[1] = 32'b111111111111_01111_000_01111_0010011; //ADDI x15,x15,-1
                memory[2] = 32'b000000000010_01111_000_01111_0010011; //ADDI x15,x15,2
                memory[3] = 32'b0000000_01111_10000_000_01111_0110011; //ADD  x15,x16,x15
                
        end

        always @(posedge clk) begin
                if (write) begin
                        memory[address] <= data_in;
                end
                else begin
                        data_out <= memory[address];
                end
        end
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
