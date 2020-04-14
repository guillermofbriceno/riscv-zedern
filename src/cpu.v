`include "cpu_fetch.v"
`include "cpu_decode.v"
`include "cpu_execute.v"
`include "cpu_memory.v"
`include "cpu_writeback.v"
`include "hazard.v"

module RV32I_CPU(
        input                clk,
        input   wire [31:0]  instruction,
        input   wire [31:0]  data_in,
        output  wire [31:0]  data_out,
        output  wire [03:0]  width,
        output  wire [09:0]  instruction_address,
        output  wire [09:0]  data_address,
        output               write_mem,
        output  wire         read_inst_enable
);

                wire [31:0]  forward_mem;
                wire [31:0]  forward_wb;
                wire [01:0]  forward_control_src1;
                wire [01:0]  forward_control_src2;
                wire [31:0]  target;
                wire [00:0]  taken;
                wire [00:0]  pc_stall;
                wire [00:0]  flush_dec;
                wire [00:0]  flush_ex;
                wire [00:0]  flush_fe;
                reg  [03:0]  width_reg = 4'b1;
                reg  [00:0]  dec_stall = 0;
                assign width = width_reg;

        Fetch fetch_stage(
                .clk(clk),
                .stall(pc_stall),
                .instruction_address(instruction_address),
                .pc_out(pc_decode),
                .target(target),
                .taken(taken)
                //.flush(flush_fe)
        );

                wire [31:0] pc_decode;

        Decode decode_stage(
                .clk(clk),
                .instruction(instruction),
                .rs1_data(rs1_data_execute),
                .rs2_data(rs2_data_execute),
                .rs1_addr_out(rs1_addr_execute),
                .rs2_addr_out(rs2_addr_execute),
                .rd_addr_out(rd_addr_out_execute),
                .funct3(funct3_execute),
                .imm_u_nosft(imm_u_nosft),
                .imm_i_noext(imm_i_noext),
                .imm_s_noext(imm_s_noext),
                .imm_b_noext(imm_b_noext),
                .imm_j_noext(imm_j_noext),
                .pc(pc_decode),
                .pc_out(pc_execute),
                .alu_func(alu_func),
                .alu_src1_mux(alu_src1_mux),
                .alu_src2_mux(alu_src2_mux),
                .reg_write_out(reg_write_execute),
                .reg_write(reg_write),
                .mem_write(mem_write_execute),
                .rd_data(rd_data),
                .rd_addr(rd_addr),
                .wb_mux(wb_mux_execute),
                .flush(flush_dec),
                .stall(dec_stall),
                .branch_control(branch_control)
        );

                wire [31:0]  rs1_data_execute;
                wire [31:0]  rs2_data_execute;
                wire [04:0]  rs1_addr_execute;
                wire [04:0]  rs2_addr_execute;
                wire [04:0]  rd_addr_out_execute;
                wire [02:0]  funct3_execute;
                wire [02:0]  branch_control;
                wire [19:0]  imm_u_nosft;
                wire [11:0]  imm_i_noext;
                wire [11:0]  imm_s_noext;
                wire [11:0]  imm_b_noext;
                wire [11:0]  imm_j_noext;
                wire [31:0]  pc_execute;
                wire [09:0]  alu_func;
                wire [00:0]  alu_src1_mux;
                wire [01:0]  alu_src2_mux;
                wire [00:0]  reg_write_execute;
                wire [00:0]  mem_write_execute;
                wire [31:0]  rd_data;
                wire [01:0]  wb_mux_execute;

        Execute execute_stage(
                .clk(clk),
                .rs1_data(rs1_data_execute),
                .rs2_data(rs2_data_execute),
                .rd_addr(rd_addr_out_execute),
                .reg_write(reg_write_execute),
                .mem_write(mem_write_execute),
                .funct3(funct3_execute),
                .funct3_out(funct3_mem),
                .branch_control(branch_control),
                .imm_u_nosft(imm_u_nosft),
                .imm_i_noext(imm_i_noext),
                .imm_s_noext(imm_s_noext),
                .imm_b_noext(imm_b_noext),
                .imm_j_noext(imm_j_noext),
                .pc(pc_execute),
                .forward_mem(forward_mem),
                .forward_wb(forward_wb),
                .forward_control_src1(forward_control_src1),
                .forward_control_src2(forward_control_src2),
                .alu_func(alu_func),
                .alu_src1_mux(alu_src1_mux),
                .alu_src2_mux(alu_src2_mux),
                .rd_addr_out(rd_addr_memory),
                .reg_write_out(reg_write_memory),
                .mem_write_out(write_mem),
                .alu_out_clocked(alu_out),
                .rs2_out(data_out),
                .wb_mux(wb_mux_execute),
                .wb_mux_out(wb_mux_memory),
                .taken(taken),
                .target(target)
        );
                assign forward_mem = alu_out;
                assign forward_wb  = rd_data;
                wire [31:0]  alu_out;
                assign       data_address = alu_out[9:0];
                wire [04:0]  rd_addr_memory;
                wire [00:0]  reg_write_memory;
                wire [01:0]  wb_mux_memory;
                wire [02:0]  funct3_mem;

        MemoryStage memory_stage(
               .clk(clk),
               .alu_out(alu_out),
               .rd_addr(rd_addr_memory),
               .reg_write(reg_write_memory),
               .wb_mux(wb_mux_memory),
               .funct3(funct3_mem),
               .alu_out_wb(alu_out_wb),
               .rd_addr_out(rd_addr),
               .reg_write_out(reg_write),
               .wb_mux_out(wb_mux),
               .funct3_out(funct3_wb)
        );
        
                wire [31:0]  alu_out_wb;
                wire [04:0]  rd_addr;
                wire [00:0]  reg_write;
                wire [01:0]  wb_mux;
                wire [02:0]  funct3_wb;

        Writeback writeback_stage(
                .alu_out(alu_out_wb),
                .data_in(data_in),
                .wb_mux(wb_mux),
                .rd_data(rd_data),
                .funct3(funct3_wb)
        );

        assign read_inst_enable = ~flush_fe;

        HazardUnit hazard(
                .rs1_addr_execute(rs1_addr_execute),
                .rs2_addr_execute(rs2_addr_execute),
                .rd_addr_mem(rd_addr_memory),
                .rd_write_mem(reg_write_memory),
                .rd_addr_wb(rd_addr),
                .rd_write_wb(reg_write),
                .forward_control_src1(forward_control_src1),
                .forward_control_src2(forward_control_src2),

                .taken(taken),
                .pc_stall(pc_stall),
                .flush_dec(flush_dec),
                .flush_fe(flush_fe)
        );


endmodule
