`include "alu.v"

module execute(
        input               clk, 

        input   wire [31:0] iA_inst,
        input   wire [31:0] iA_rs1_data,
        input   wire [31:0] iA_rs2_data, 
        input   wire        iA_rs1_active,
        input   wire        iA_rs2_active,
        input   wire [ 4:0] iA_rd_addr, 
        input   wire [ 0:0] iA_reg_write,
        input   wire [ 2:0] iA_src1_mux,
        input   wire [ 2:0] iA_src2_mux,
        input   wire [ 9:0] iA_alu_func,
        input   wire [31:0] iA_pc,
        input   wire [ 0:0] iA_mem_write,
    
        input   wire [ 0:0] A_flush,
        input   wire [ 0:0] B_flush,
        
        output  reg  [31:0] oA_alu_out,
        );

        reg  [31:0] A_rs1_data;
        reg  [31:0] A_rs2_data;
        reg  [31:0] A_alu_in1;
        reg  [31:0] A_alu_in2;
        wire [31:0] A_alu_out;

        /* 
        *  EX/MEM Issue A Pipeline Buffer
        */
        always @(posedge clk) begin
                if (A_flush) begin
                        oA_reg_write    <= 0;
                        oA_rd_addr      <= 5'b0;
                        oA_mem_write    <= 0;
                end else begin
                        oA_reg_write    <= iA_reg_write;
                        oA_rd_addr      <= iA_rd_addr;
                        oA_mem_write    <= iA_mem_write;
                end

                oa_alu_out <= a_alu_out;
        end

        /* 
        *  EX/MEM Issue B Pipeline Buffer
        */
        always @(posedge clk) begin
                if (B_flush) begin
                        oB_reg_write    <= 0;
                        oB_rd_addr      <= 5'b0;
                end else begin
                        oB_reg_write    <= iB_reg_write;
                        oB_rd_addr      <= iB_rd_addr;
                end

                ob_alu_out <= b_alu_out;
        end

        /* 
        *  Issue A Input and Data Forwarding Muxes
        */
        always @ (*) begin
                case(A_forward_mux_src1)
                        `REG_DATA:  A_rs1_data <= iA_rs1_data;
                        `A_FWD_MEM: A_rs1_data <= 32'b0;
                        `A_FWD_WB:  A_rs1_data <= 32'b0;
                        `B_FWD_MEM: A_rs1_data <= 32'b0;
                        `B_FWD_WB:  A_rs1_data <= 32'b0;
                        default:    A_rs1_data <= iA_rs1_data;
                endcase

                case(A_forward_mux_src2)
                        `REG_DATA:  A_rs2_data <= iA_rs2_data;
                        `A_FWD_MEM: A_rs2_data <= 32'b0;
                        `A_FWD_WB:  A_rs2_data <= 32'b0;
                        `B_FWD_MEM: A_rs2_data <= 32'b0;
                        `B_FWD_WB:  A_rs2_data <= 32'b0;
                        default:    A_rs2_data <= iA_rs2_data;
                endcase

                case(iA_src1_mux)
                        `RS1_SEL:   A_alu_in1 <= A_rs1_data;
                        `U_IMM_SEL: A_alu_in1 <= 32'b0;
                        default:    A_alu_in1 <= A_rs1_data;
                endcase

                case(iA_src2_mux)
                        `RS2_SEL:   A_alu_in2 <= A_rs2_data;
                        `S_IMM_SEL: A_alu_in2 <= 32'b0;
                        `I_IMM_SEL: A_alu_in2 <= 32'b0;
                        `PC_SEL:    A_alu_in2 <= 32'b0;
                        default:    A_alu_in2 <= A_rs2_data;
                endcase
        end

        /* 
        *  Issue B Input and Data Forwarding Muxes
        */
        always @ (*) begin
                case(B_forward_mux_src1)
                        `REG_DATA:  B_rs1_data <= iB_rs1_data;
                        `A_FWD_MEM: B_rs1_data <= 32'b0;
                        `A_FWD_WB:  B_rs1_data <= 32'b0;
                        `B_FWD_MEM: B_rs1_data <= 32'b0;
                        `B_FWD_WB:  B_rs1_data <= 32'b0;
                        default:    B_rs1_data <= iB_rs1_data;
                endcase

                case(B_forward_mux_src2)
                        `REG_DATA:  B_rs2_data <= iB_rs2_data;
                        `A_FWD_MEM: B_rs2_data <= 32'b0;
                        `A_FWD_WB:  B_rs2_data <= 32'b0;
                        `B_FWD_MEM: B_rs2_data <= 32'b0;
                        `B_FWD_WB:  B_rs2_data <= 32'b0;
                        default:    B_rs2_data <= iB_rs2_data;
                endcase

                case(iB_src1_mux)
                        `RS1_SEL:   B_alu_in1 <= B_rs1_data;
                        `U_IMM_SEL: B_alu_in1 <= 32'b0;
                        default:    B_alu_in1 <= B_rs1_data;
                endcase

                case(iB_src2_mux)
                        `RS2_SEL:   B_alu_in2 <= B_rs2_data;
                        `S_IMM_SEL: B_alu_in2 <= 32'b0;
                        `I_IMM_SEL: B_alu_in2 <= 32'b0;
                        `PC_SEL:    B_alu_in2 <= 32'b0;
                        default:    B_alu_in2 <= B_rs2_data;
                endcase
        end

        Alu A_ALU (
                .in1(A_alu_in1),
                .in2(A_alu_in2),
                .out(A_alu_out),
                .func(iA_alu_func),
                .alu_branch(A_alu_branch)
        );

endmodule
