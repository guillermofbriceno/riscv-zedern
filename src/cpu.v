`include "components.v"
`include "defs.v"

module Cpu(clk, instruction, data_in, data_out, width, address_instruction, address_data, write_mem);
        input clk; 
        input [31:0] instruction, data_in;
        output [31:0] data_out, address_instruction, address_data;
        output [01:0] width;
        output write_mem;

        wire            [04:0] rs1_addr;
        wire            [04:0] rs2_addr;
        wire            [31:0] rs1_out;
        wire            [31:0] rs2_out;
        wire            [04:0] rd_addr;
        reg             [31:0] rd_data;
        wire            [31:0] alu_out;
        wire            [09:0] alu_func;
        wire            [09:0] alu_func_s;
        wire            [02:0] alu_branch;

        reg             [31:0] pc               = 32'h200;
        wire            [31:0] pc_p4;
        wire            [31:0] pc_p_brch;
        wire            [31:0] pc_p_jmp;
        wire            [31:0] pc_rs1_p_i;
        reg                    cond_branch;
        wire                   taken;
        wire            [02:0] funct3;
        reg             [31:0] pc_next;
        reg             [01:0] mux_pc           = 2'b0;
        wire            [09:0] instruction_type;
        reg             [11:0] control;
        wire            [31:0] imm_u;
        wire            [31:0] imm_i;
        wire            [31:0] imm_s;
        wire            [31:0] imm_b;
        wire            [31:0] imm_j;

        reg             [31:0] adjusted_data_in;

        reg             [31:0] alu_in1          = 32'b0;
        reg             [31:0] alu_in2          = 32'b0;

        reg             [01:0] mux_wb;

        wire            [03:0] cond_branch_ctrl;

        always @ (posedge clk) begin
                pc <= pc_next;
        end

        assign pc_p4               = pc + 4;
        assign pc_p_brch           = pc + imm_b;
        //assign pc_p_brch           = pc + {{19{imm_b[12]}}, imm_b};
        assign pc_p_jmp            = pc + imm_j;
        assign pc_rs1_p_i          = pc + rs1_out;
        assign address_instruction = pc;
        assign taken               = control[`COND_BR_IDX] & cond_branch;

        assign cond_branch_ctrl = {control[`BRANCH_ENC], taken};

        always @ (cond_branch_ctrl, pc_p4, pc_p_brch) begin
                case(cond_branch_ctrl)
                        `NO_BRANCH_SEL:  pc_next = pc_p4;
                        `COND_BR_SEL:    pc_next = pc_p_brch;
                        `JAL_SEL:        pc_next = pc_p_jmp;
                        `JALR_SEL:       pc_next = pc_p4;
                        default:         pc_next = pc_p4;
                endcase
        end

        always @ (alu_branch, cond_branch, funct3) begin
                case(funct3)
                        `BEQ:    cond_branch =  alu_branch[`EQ_IDX];
                        `BNE:    cond_branch = ~alu_branch[`EQ_IDX];
                        `BLT:    cond_branch =  alu_branch[`LTS_IDX];
                        `BGE:    cond_branch = ~alu_branch[`LTS_IDX];
                        `BLTU:   cond_branch =  alu_branch[`LTU_IDX];
                        `BGEU:   cond_branch = ~alu_branch[`LTU_IDX];
                        default: cond_branch = 0;
                endcase
        end

        assign rs1_addr   = instruction[19:15];
        assign rs2_addr   = instruction[24:20];
        assign rd_addr    = instruction[11:07];
        assign imm_u      = instruction[31:12] << 12;
        assign imm_i      = {{20{instruction[31]}}, instruction[31:20]};
        assign imm_s      = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]}; // could use imm_i?
        assign imm_b      = {{20{instruction[31]}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0};
        assign imm_j      = {{20{instruction[31]}}, instruction[19:12], instruction[20], instruction[30:21], 1'b0};
        assign alu_func   = control[`ALU_FUNC_MUX]  ? alu_func_s : 10'b0;
        assign alu_func_s = control[`ALU_FWIDE_MUX] ? {instruction[31:25], instruction[14:12]} : {7'b0, instruction[14:12]};
        assign funct3     = instruction[14:12];
        assign width      = funct3[1:0];
        assign address_data = {20'b0, alu_out[31:12]};
        assign data_out   = rs2_out;
        assign write_mem  = control[`MEMWRITE_SIG];

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
                                            | ((instruction & `R_MASK)    == `AND_OP  ) | 10'b0;
        
        assign instruction_type[`SHFI_IDX] = 1'b0;

        always @ (instruction_type) begin
                case(instruction_type)
                        `LUI:    control = `LUI_CTRL;
                        `AUIPC:  control = `AUIPC_CTRL;
                        `STRS:   control = `STRS_CTRL;
                        `LODS:   control = `LODS_CTRL;
                        `ALUI:   control = `ALUI_CTRL;
                        `ALUR:   control = `ALUR_CTRL;
                        `LODS:   control = `LODS_CTRL;
                        `BRCH:   control = `BRCH_CTRL;
                        `JAL:    control = `JAL_CTRL;
                        `JALR:   control = `JALR_CTRL;
                        default: control = `NOP;
                endcase
        end

        always @(imm_s, imm_i, rs2_out, pc, control) begin
                case(control[`ALU_SRC2_MUX])
                        `RS2_SEL:   alu_in2 = rs2_out;
                        `S_IMM_SEL: alu_in2 = imm_s;
                        `I_IMM_SEL: alu_in2 = imm_i;
                        `PC_SEL:    alu_in2 = pc;
                endcase
        end

        always @(imm_u, rs1_out, control) begin
                case(control[`ALU_SRC1_MUX]) 
                        `U_IMM_SEL: alu_in1 = imm_u;
                        `RS1_SEL:   alu_in1 = rs1_out;
                endcase
        end

        Alu ALU(
                .in1(alu_in1),
                .in2(alu_in2),
                .out(alu_out),
                .func(alu_func),
                .alu_branch(alu_branch)
        );

        always @(funct3, data_in) begin
                case(funct3)
                        `LB:     adjusted_data_in = {{24{data_in[7]}}, data_in[7:0]};
                        `LH:     adjusted_data_in = {{16{data_in[15]}}, data_in[15:0]};
                        `LBU:    adjusted_data_in = {24'b0, data_in[7:0]};
                        `LHU:    adjusted_data_in = {16'b0, data_in[15:0]};
                        default: adjusted_data_in = data_in;
                endcase
        end

        always @(adjusted_data_in, pc_p4, alu_out, control) begin
                case(control[`WRB_REGF_MUX])
                        `ALUOUT_SEL: rd_data = alu_out;
                        `PC_P_4_SEL: rd_data = pc_p4;
                        `DTAMEM_SEL: rd_data = adjusted_data_in;
                endcase
        end

        RegisterFile IntegerRF (
                .rs1_addr(rs1_addr),
                .rs2_addr(rs2_addr),
                .rs1_out(rs1_out),
                .rs2_out(rs2_out),
                .rd_addr(rd_addr),
                .rd_data(rd_data),
                .write(control[`REGWRITE_SIG]),
                .clk(clk)
        );

endmodule
