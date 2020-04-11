`include "defs.v"
`include "alu.v"

module Execute(
        input                clk, 
        input   wire [31:0]  rs1_data, 
        input   wire [31:0]  rs2_data, 
        input   wire [ 4:0]  rd_addr, 
        input   wire [ 0:0]  reg_write,
        input   wire [ 0:0]  mem_write,
        input   wire [19:0]  imm_u_nosft, 
        input   wire [11:0]  imm_i_noext, 
        input   wire [11:0]  imm_s_noext, 
        //input   wire [11:0]  pc,
        
        input   wire [31:0]  forward_mem,
        input   wire [31:0]  forward_wb,
        input   wire [ 1:0]  forward_control_src1,
        input   wire [ 1:0]  forward_control_src2,
        input   wire [ 9:0]  alu_func,

        input   wire [0:0]   alu_src1_mux,
        input   wire [1:0]   alu_src2_mux,

        output  reg  [ 4:0]  rd_addr_out,
        output  reg  [ 0:0]  reg_write_out,
        output  reg  [31:0]  alu_out_clocked,
        output  reg  [ 0:0]  mem_write_out,
        output  reg  [31:0]  rs2_out
);
                reg  [31:0]  rs1;
                reg  [31:0]  rs2;
                wire [31:0]  alu_out;
                reg  [31:0]  alu_in1;
                reg  [31:0]  alu_in2;
                wire [02:0]  alu_branch;

        always @ (posedge clk) begin
                rd_addr_out     <= rd_addr;
                alu_out_clocked <= alu_out;
                rs2_out         <= rs2_data;
                reg_write_out   <= reg_write;
                mem_write_out   <= mem_write;
        end

        always @ (*) begin
                case(forward_control_src1)
                        `RS_DATA:   rs1     <= rs1_data;
                        `FWD_MEM:   rs1     <= forward_mem;
                        `FWD_WB:    rs1     <= forward_wb;
                endcase

                case (forward_control_src2)
                        `RS_DATA:   rs2     <= rs2_data;
                        `FWD_MEM:   rs2     <= forward_mem;
                        `FWD_WB:    rs2     <= forward_wb;
                endcase

                case(alu_src1_mux) 
                        `U_IMM_SEL: alu_in1 <= {imm_u_nosft, 12'b0};
                        `RS1_SEL:   alu_in1 <= rs1;
                endcase

                case(alu_src2_mux)
                        `RS2_SEL:   alu_in2 <= rs2;
                        `S_IMM_SEL: alu_in2 <= {{20{imm_s_noext[11]}}, imm_s_noext};
                        `I_IMM_SEL: alu_in2 <= {{20{imm_i_noext}}, imm_i_noext};
                        //`PC_SEL:    alu_in2 <= pc;
                endcase

                
        end

        Alu IntegerALU (
                .in1(alu_in1),
                .in2(alu_in2),
                .out(alu_out),
                .func(alu_func),
                .alu_branch(alu_branch)
        );



endmodule
