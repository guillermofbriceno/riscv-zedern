
module MemoryStage(
        input                clk,
        input   wire [31:0]  alu_out,
        input   wire [04:0]  rd_addr,
        input   wire [00:0]  reg_write,
        input   wire [ 1:0]  wb_mux,
        input   wire [ 2:0]  funct3,

        output  reg  [31:0]  alu_out_wb,
        output  reg  [04:0]  rd_addr_out,
        output  reg  [00:0]  reg_write_out,
        output  reg  [01:0]  wb_mux_out,
        output  reg  [02:0]  funct3_out
);

        always @ (posedge clk) begin
                alu_out_wb      <= alu_out;
                rd_addr_out     <= rd_addr;
                reg_write_out   <= reg_write;
                wb_mux_out      <= wb_mux;
        end
        
endmodule
