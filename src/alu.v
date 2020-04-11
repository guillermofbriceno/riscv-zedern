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
                        //10'b0000001_000: out = in1 *   in2;
                        default:         out = 32'b0;
                endcase

                alu_branch[`EQ_IDX]  <= in1 == in2;
                alu_branch[`LTS_IDX] <= (in1[31] != in2[31]) ? in2[31] : sub[31];
                alu_branch[`LTU_IDX] <= in1 <  in2;
        end


endmodule
