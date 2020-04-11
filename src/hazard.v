`include "defs.v"

module HazardUnit(
        input   wire [4:0]  rs1_addr_execute,
        input   wire [4:0]  rs2_addr_execute,
        input   wire [4:0]  rd_addr_mem,
        input   wire [0:0]  rd_write_mem,
        input   wire [4:0]  rd_addr_wb,
        input   wire [0:0]  rd_write_wb,

        output  reg  [1:0]  forward_control_src1,
        output  reg  [1:0]  forward_control_src2
);

        always @ (*) begin
                if          ((rs1_addr_execute == rd_addr_mem) & rd_write_mem) begin
                        forward_control_src1 <= `FWD_MEM;
                end else if ((rs1_addr_execute == rd_addr_wb)  & rd_write_wb)  begin
                        forward_control_src1 <= `FWD_WB;
                end else begin
                        forward_control_src1 <= `RS_DATA;
                end

                if          ((rs2_addr_execute == rd_addr_mem) & rd_write_mem) begin
                        forward_control_src2 <= `FWD_MEM;
                end else if ((rs2_addr_execute == rd_addr_wb)  & rd_write_wb)  begin
                        forward_control_src2 <= `FWD_WB;
                end else begin
                        forward_control_src2 <= `RS_DATA;
                end
        end

endmodule
