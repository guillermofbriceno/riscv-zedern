`include "defs.v"
`include "register_file.v"

module Decode(
        input   wire         clk,
        input   wire [31:0]  instruction,
        input   wire [31:0]  pc,
        output  reg  [31:0]  pc_out,
        output  wire [31:0]  rs1_data,
        output  wire [31:0]  rs2_data,
        output  reg  [ 4:0]  rs1_addr_out,
        output  reg  [ 4:0]  rs2_addr_out,
        output  reg  [ 4:0]  rd_addr_out,
        output  reg  [ 2:0]  funct3,
        output  reg  [19:0]  imm_u_nosft,
        output  reg  [11:0]  imm_i_noext,
        output  reg  [11:0]  imm_s_noext,
        output  reg  [11:0]  imm_b_noext,
        output  reg  [11:0]  imm_j_noext,
        output  reg  [ 9:0]  alu_func,
        output  reg  [ 0:0]  alu_src1_mux,
        output  reg  [ 1:0]  alu_src2_mux,
        output  reg  [ 0:0]  reg_write_out,
        output  reg  [ 0:0]  mem_write,
        output  reg  [ 1:0]  wb_mux,
        output  reg  [ 2:0]  branch_control,
        output  reg  [ 0:0]  load_ex,
        input   wire [31:0]  rd_data,
        input   wire [ 4:0]  rd_addr,
        input   wire [ 0:0]  reg_write,
        input   wire [ 0:0]  flush,
        input   wire [ 0:0]  stall
        );
                wire [09:0] alu_func_s;
                reg  [12:0] control;
                wire [09:0] instruction_type;
                wire [ 4:0] rs1_addr;
                wire [ 4:0] rs2_addr;

        assign rs1_addr     = instruction[19:15];
        assign rs2_addr     = instruction[24:20];

        always @ (posedge clk) begin
                if (!stall) begin
                        rs1_addr_out <= rs1_addr;
                        rs2_addr_out <= rs2_addr;
                        rd_addr_out  <= instruction[11:07];
                        imm_u_nosft  <= instruction[31:12];
                        imm_i_noext  <= instruction[31:20];
                        imm_s_noext  <= {instruction[31:25], instruction[11:7]};
                        imm_s_noext  <= {instruction[31:25], instruction[11:7]};
                        imm_b_noext  <= {instruction[31], instruction[7], instruction[30:25], instruction[11:8]};
                        imm_j_noext  <= {instruction[19:12], instruction[20], instruction[30:21]};
                        //imm_u        <= instruction[31:12] << 12;
                        //imm_i        <= {{20{instruction[31]}}, instruction[31:20]};
                        //imm_s        <= {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
                        alu_src1_mux <= control[`ALU_SRC1_MUX];
                        alu_src2_mux <= control[`ALU_SRC2_MUX];
                        pc_out       <= pc;

                        if (flush) begin
                                alu_func       <= 10'b0;
                                reg_write_out  <= 0;
                                mem_write      <= 0;
                                wb_mux         <= 2'b0;
                                funct3         <= 3'b0;
                                branch_control <= 3'b0;
                                load_ex        <= 1'b0;
                        end else begin
                                alu_func       <= control[`ALU_FUNC_MUX]  ? alu_func_s : 10'b0;
                                reg_write_out  <= control[`REGWRITE_SIG];
                                mem_write      <= control[`MEMWRITE_SIG];
                                wb_mux         <= control[`WRB_REGF_MUX];
                                funct3         <= instruction[14:12];
                                branch_control <= control[`BRANCH_ENC];
                                load_ex        <= control[`LOAD_SIG];
                        end
                end
        end

        always @ (*) begin
                case(instruction_type)
                        `LUI:    control <= `LUI_CTRL;
                        `AUIPC:  control <= `AUIPC_CTRL;
                        `STRS:   control <= `STRS_CTRL;
                        `LODS:   control <= `LODS_CTRL;
                        `ALUI:   control <= `ALUI_CTRL;
                        `ALUR:   control <= `ALUR_CTRL;
                        `BRCH:   control <= `BRCH_CTRL;
                        `JAL:    control <= `JAL_CTRL;
                        `JALR:   control <= `JALR_CTRL;
                        default: control <= `NOP;
                endcase
        end

        //assign imm_j      = {{20{instruction[31]}}, instruction[19:12], instruction[20], instruction[30:21], 1'b0};
        //assign imm_b      = {{20{instruction[31]}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0};
        assign alu_func_s = control[`ALU_FWIDE_MUX] ? {instruction[31:25], instruction[14:12]} : {7'b0, instruction[14:12]};

        assign instruction_type[`LUI_IDX  ] = ((instruction & `UJ_MASK)   == `LUI_OP  ) | 10'b0;
        assign instruction_type[`AUIPC_IDX] = ((instruction & `UJ_MASK)   == `AUIPC_OP) | 10'b0;
        assign instruction_type[`JAL_IDX  ] = ((instruction & `UJ_MASK)   == `JAL_OP  ) | 10'b0;
        assign instruction_type[`JALR_IDX ] = ((instruction & `ISB_MASK)  == `JALR_OP ) | 10'b0;
        assign instruction_type[`BRCH_IDX ] = ((instruction & `ISB_MASK)  == `BEQ_OP  )
                                            | ((instruction & `ISB_MASK)  == `BNE_OP  )
                                            | ((instruction & `ISB_MASK)  == `BLT_OP  )
                                            | ((instruction & `ISB_MASK)  == `BGE_OP  )
                                            | ((instruction & `ISB_MASK)  == `BLTU_OP )
                                            | ((instruction & `ISB_MASK)  == `BGEU_OP ) | 10'b0;
        assign instruction_type[`LODS_IDX ] = ((instruction & `ISB_MASK)  == `LB_OP   )
                                            | ((instruction & `ISB_MASK)  == `LH_OP   )
                                            | ((instruction & `ISB_MASK)  == `LW_OP   )
                                            | ((instruction & `ISB_MASK)  == `LBU_OP  )
                                            | ((instruction & `ISB_MASK)  == `LHU_OP  ) | 10'b0;
        assign instruction_type[`STRS_IDX ] = ((instruction & `ISB_MASK)  == `SB_OP   )
                                            | ((instruction & `ISB_MASK)  == `SH_OP   )
                                            | ((instruction & `ISB_MASK)  == `SW_OP   ) | 10'b0;
        assign instruction_type[`ALUI_IDX ] = ((instruction & `ISB_MASK)  == `ADDI_OP )
                                            | ((instruction & `ISB_MASK)  == `SLTI_OP )
                                            | ((instruction & `ISB_MASK)  == `SLTIU_OP)
                                            | ((instruction & `ISB_MASK)  == `XORI_OP )
                                            | ((instruction & `ISB_MASK)  == `ORI_OP  )
                                            | ((instruction & `ISB_MASK)  == `ANDI_OP )
                                            | ((instruction & `ISB_MASK)  == `SLLI_OP )
                                            | ((instruction & `ISB_MASK)  == `SRLI_OP )
                                            | ((instruction & `ISB_MASK)  == `SRAI_OP ) | 10'b0;
        assign instruction_type[`ALUR_IDX ] = ((instruction & `R_MASK)    == `ADD_OP  )
                                            | ((instruction & `R_MASK)    == `SUB_OP  )
                                            | ((instruction & `R_MASK)    == `SLL_OP  )
                                            | ((instruction & `R_MASK)    == `SLT_OP  )
                                            | ((instruction & `R_MASK)    == `SLTU_OP )
                                            | ((instruction & `R_MASK)    == `XOR_OP  )
                                            | ((instruction & `R_MASK)    == `SRL_OP  )
                                            | ((instruction & `R_MASK)    == `SRA_OP  )
                                            | ((instruction & `R_MASK)    == `OR_OP   )
                                            | ((instruction & `R_MASK)    == `MUL_OP  )
                                            | ((instruction & `R_MASK)    == `AND_OP  ) | 10'b0;
        assign instruction_type[`SHFI_IDX] = 1'b0;
        
        RegisterFile IntegerRF(
                .rs1_addr(rs1_addr),
                .rs2_addr(rs2_addr),
                .rs1_out(rs1_data),
                .rs2_out(rs2_data),
                .rd_addr(rd_addr),
                .rd_data(rd_data),
                .write(reg_write),
                .clk(clk)
        );
                

endmodule
