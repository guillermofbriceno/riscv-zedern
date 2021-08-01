`include "alu.v"

module Execute(
        input               clk, 

        input   wire [31:0] ia_inst,
        input   wire [31:0] ia_rs1_data,
        input   wire [31:0] ia_rs2_data, 
        input   wire        ia_rs1_active,
        input   wire        ia_rs2_active,
        input   wire [ 4:0] ia_rd_addr, 
        input   wire [ 0:0] ia_reg_write,
        input   wire [ 2:0] ia_src1_mux,
        input   wire [ 2:0] ia_src2_mux,
        input   wire [ 9:0] ia_alu_func,
        input   wire [31:0] ia_pc,
        input   wire [ 0:0] ia_mem_write,
    
        input   wire [ 0:0] a_flush,
        input   wire [ 0:0] b_flush,
        
        output  reg  [31:0] oa_alu_out,
        );

        reg  [31:0] a_rs1_data;
        reg  [31:0] a_rs2_data;
        reg  [31:0] a_alu_in1;
        reg  [31:0] a_alu_in2;
        wire [31:0] a_alu_out;

        /* 
        *  EX/MEM Issue A Pipeline Buffer
        */
        always @(posedge clk) begin
                if (a_flush) begin
                        oa_reg_write    <= 0;
                        oa_rd_addr      <= 5'b0;
                        oa_mem_write    <= 0;
                end else begin
                        oa_reg_write    <= ia_reg_write;
                        oa_rd_addr      <= ia_rd_addr;
                        oa_mem_write    <= ia_mem_write;
                end

                oa_alu_out <= a_alu_out;
        end

        /* 
        *  EX/MEM Issue B Pipeline Buffer
        */
        always @(posedge clk) begin
                if (b_flush) begin
                        ob_reg_write    <= 0;
                        ob_rd_addr      <= 5'b0;
                end else begin
                        ob_reg_write    <= ib_reg_write;
                        ob_rd_addr      <= ib_rd_addr;
                end

                ob_alu_out <= b_alu_out;
        end

        /* 
        *  Issue A Input and Data Forwarding Muxes
        */
        always @ (*) begin
                case(a_forward_mux_src1)
                        `REG_DATA:  a_rs1_data <= ia_rs1_data;
                        `A_FWD_MEM: a_rs1_data <= 32'b0;
                        `A_FWD_WB:  a_rs1_data <= 32'b0;
                        `B_FWD_MEM: a_rs1_data <= 32'b0;
                        `B_FWD_WB:  a_rs1_data <= 32'b0;
                        default:    a_rs1_data <= ia_rs1_data;
                endcase

                case(a_forward_mux_src2)
                        `REG_DATA:  a_rs2_data <= ia_rs2_data;
                        `A_FWD_MEM: a_rs2_data <= 32'b0;
                        `A_FWD_WB:  a_rs2_data <= 32'b0;
                        `B_FWD_MEM: a_rs2_data <= 32'b0;
                        `B_FWD_WB:  a_rs2_data <= 32'b0;
                        default:    a_rs2_data <= ia_rs2_data;
                endcase

                case(ia_src1_mux)
                        `RS1_SEL:   a_alu_in1 <= a_rs1_data;
                        `U_IMM_SEL: a_alu_in1 <= 32'b0;
                        default:    a_alu_in1 <= a_rs1_data;
                endcase

                case(ia_src2_mux)
                        `RS2_SEL:   a_alu_in2 <= a_rs2_data;
                        `S_IMM_SEL: a_alu_in2 <= 32'b0;
                        `I_IMM_SEL: a_alu_in2 <= 32'b0;
                        `PC_SEL:    a_alu_in2 <= 32'b0;
                        default:    a_alu_in2 <= a_rs2_data;
                endcase
        end

        /* 
        *  Issue B Input and Data Forwarding Muxes
        */
        always @ (*) begin
                case(b_forward_mux_src1)
                        `REG_DATA:  b_rs1_data <= ib_rs1_data;
                        `A_FWD_MEM: b_rs1_data <= 32'b0;
                        `A_FWD_WB:  b_rs1_data <= 32'b0;
                        `B_FWD_MEM: b_rs1_data <= 32'b0;
                        `B_FWD_WB:  b_rs1_data <= 32'b0;
                        default:    b_rs1_data <= ib_rs1_data;
                endcase

                case(b_forward_mux_src2)
                        `REG_DATA:  b_rs2_data <= ib_rs2_data;
                        `A_FWD_MEM: b_rs2_data <= 32'b0;
                        `A_FWD_WB:  b_rs2_data <= 32'b0;
                        `B_FWD_MEM: b_rs2_data <= 32'b0;
                        `B_FWD_WB:  b_rs2_data <= 32'b0;
                        default:    b_rs2_data <= ib_rs2_data;
                endcase

                case(ib_src1_mux)
                        `RS1_SEL:   b_alu_in1 <= b_rs1_data;
                        `U_IMM_SEL: b_alu_in1 <= 32'b0;
                        default:    b_alu_in1 <= b_rs1_data;
                endcase

                case(ib_src2_mux)
                        `RS2_SEL:   b_alu_in2 <= b_rs2_data;
                        `S_IMM_SEL: b_alu_in2 <= 32'b0;
                        `I_IMM_SEL: b_alu_in2 <= 32'b0;
                        `PC_SEL:    b_alu_in2 <= 32'b0;
                        default:    b_alu_in2 <= b_rs2_data;
                endcase
        end

        Alu A_ALU (
                .in1(0_alu_in1),
                .in2(0_alu_in2),
                .out(0_alu_out),
                .func(i0_alu_func),
                .alu_branch(0_alu_branch)
        );

endmodule
