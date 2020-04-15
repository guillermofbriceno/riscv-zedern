
module MemoryStage(
        input                clk,
        input   wire [31:0]  alu_out,
        input   wire [04:0]  rd_addr,
        input   wire [00:0]  reg_write,
        input   wire [ 1:0]  wb_mux,
        input   wire [ 2:0]  funct3,
        input   wire [31:0]  rs2_out,
        input   wire [31:0]  pc,

        output  reg  [31:0]  alu_out_wb,
        output  reg  [04:0]  rd_addr_out,
        output  reg  [00:0]  reg_write_out,
        output  reg  [01:0]  wb_mux_out,
        output  reg  [02:0]  funct3_out,
        output  reg  [03:0]  width,
        output  reg  [31:0]  data_out,
        output  reg  [31:0]  pc_out
);

        always @ (posedge clk) begin
                alu_out_wb      <= alu_out;
                rd_addr_out     <= rd_addr;
                reg_write_out   <= reg_write;
                wb_mux_out      <= wb_mux;
                pc_out          <= pc;
        end

        always @ (*) begin
                case (funct3[1:0])
                        `WR_WORD: begin
                                data_out <= rs2_out;
                                width    <= 4'b1111;
                        end
                        `WR_HALFWORD: begin
                                data_out <= rs2_out[15:0] << (alu_out[1] << 1);
                                width    <= 2'b11 << (alu_out[1] << 1);
                        end
                        `WR_BYTE: begin
                                data_out <= rs2_out[7:0] << alu_out[1:0];
                                width    <= 1'b1 << alu_out[1:0];
                        end
                        default: begin
                                data_out <= rs2_out;
                                width    <= 4'b1111;
                        end

                endcase

        end
        
endmodule
