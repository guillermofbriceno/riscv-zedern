`include "defs.v"

module HazardUnit(
        input   wire [4:0]  rs1_addr_execute,
        input   wire [4:0]  rs2_addr_execute,
        input   wire [4:0]  rd_addr_mem,
        input   wire [0:0]  rd_write_mem,
        input   wire [4:0]  rd_addr_wb,
        input   wire [0:0]  rd_write_wb,
        input   wire [0:0]  taken,
        input   wire [0:0]  load,

        output  reg  [1:0]  forward_control_src1,
        output  reg  [1:0]  forward_control_src2,
        output  reg  [0:0]  pc_stall = 0,
        //output  reg  [0:0]  fe_stall = 0,
        output  reg  [0:0]  flush_dec= 0,
        output  reg  [0:0]  flush_fe = 0,
        output  reg  [0:0]  flush_ex = 0
);

        always @ (*) begin
                if          ((rs1_addr_execute == rd_addr_mem) & rd_write_mem & (rd_addr_mem != 5'b0)) begin
                        forward_control_src1 <= `FWD_MEM;
                end else if ((rs1_addr_execute == rd_addr_wb)  & rd_write_wb  & (rd_addr_wb  != 5'b0))  begin
                        forward_control_src1 <= `FWD_WB;
                end else begin
                        forward_control_src1 <= `RS_DATA;
                end

                if          ((rs2_addr_execute == rd_addr_mem) & rd_write_mem & (rd_addr_mem != 5'b0)) begin
                        forward_control_src2 <= `FWD_MEM;
                end else if ((rs2_addr_execute == rd_addr_wb)  & rd_write_wb  & (rd_addr_wb  != 5'b0))  begin
                        forward_control_src2 <= `FWD_WB;
                end else begin
                        forward_control_src2 <= `RS_DATA;
                end

                case ({taken, load})
                        2'b10: begin
                                flush_fe  <= 1;
                                flush_dec <= 1;
                                pc_stall  <= 0;
                        end
                        2'b01: begin
                                flush_fe  <= 0;
                                flush_dec <= 1;
                                pc_stall  <= 1;
                        end
                        default begin
                                flush_fe  <= 0;
                                flush_dec <= 0;
                                pc_stall  <= 0;
                        end
                endcase
        end

endmodule
