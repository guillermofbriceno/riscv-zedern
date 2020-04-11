module RegisterFile(rs1_addr, rs2_addr, rs1_out, rs2_out, rd_addr, rd_data, write, clk);
        input [4:0] rs1_addr, rs2_addr, rd_addr;
        input [31:0]rd_data;
        input write;
        input clk;
        output reg [31:0] rs1_out, rs2_out;

        reg [31:0] registers [31:0];

        //assign rs1_out = registers[rs1_addr];
        //assign rs2_out = registers[rs2_addr];

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

        always @ (posedge clk) begin
                rs1_out <= registers[rs1_addr];
                rs2_out <= registers[rs2_addr];
        end
endmodule

