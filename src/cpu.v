`include "cpu_fetch.v"
`include "cpu_decode.v"
`include "cpu_execute.v"
`include "cpu_memory.v"
`include "cpu_writeback.v"

module RV32I_CPU(
        input                clk,
        input   wire [31:0]  instruction,
        input   wire [31:0]  data_in,
        output  wire [31:0]  data_out,
        output  wire [03:0]  width,
        output  wire [09:0]  instruction_address,
        output  wire [09:0]  data_address,
        output               write_mem
);

                wire [31:0]  forward_mem;
                wire [31:0]  forward_wb;
                reg  [01:0]  forward_control_src1 = 2'b0;
                reg  [01:0]  forward_control_src2 = 2'b0;

        Fetch fetch_stage(
                .clk(clk),
                .instruction_address(instruction_address)
        );

        Decode decode_stage(
                .clk(clk),
                .instruction(instruction),
                .rs1_data(rs1_data_execute),
                .rs2_data(rs2_data_execute),
                .rs1_addr(rs1_addr_execute),
                .rs2_addr(rs2_addr_execute),
                .rd_addr_out(rd_addr_out_execute),
                .imm_u_nosft(imm_u_nosft),
                .imm_i_noext(imm_i_noext),
                .imm_s_noext(imm_s_noext),
                //.pc(pc_execute),
                .alu_func(alu_func),
                .alu_src1_mux(alu_src1_mux),
                .alu_src2_mux(alu_src2_mux),
                .reg_write_out(reg_write_execute),
                .reg_write(reg_write),
                .mem_write(mem_write_execute),
                .rd_data(rd_data),
                .rd_addr(rd_addr),
                .wb_mux(wb_mux_execute)
        );

                wire [31:0]  rs1_data_execute;
                wire [31:0]  rs2_data_execute;
                wire [04:0]  rs1_addr_execute;
                wire [04:0]  rs2_addr_execute;
                wire [04:0]  rd_addr_out_execute;
                wire [19:0]  imm_u_nosft;
                wire [11:0]  imm_i_noext;
                wire [11:0]  imm_s_noext;
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
                .imm_u_nosft(imm_u_nosft),
                .imm_i_noext(imm_i_noext),
                .imm_s_noext(imm_s_noext),
                //.pc(pc_execute),
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
                .rs2_out(data_out)
        );
                wire [31:0]  alu_out;
                assign       data_address = alu_out[9:0];
                wire [04:0]  rd_addr_memory;
                wire [00:0]  reg_write_memory;
                wire [01:0]  wb_mux_memory;

        MemoryStage memory_stage(
               .clk(clk),
               .alu_out(alu_out),
               .rd_addr(rd_addr_memory),
               .reg_write(reg_write_memory),
               .wb_mux(wb_mux_memory),
               .alu_out_wb(alu_out_wb),
               .rd_addr_out(rd_addr),
               .reg_write_out(reg_write),
               .wb_mux_out(wb_mux)
        );
        
                wire [31:0]  alu_out_wb;
                wire [04:0]  rd_addr;
                wire [00:0]  reg_write;
                wire [01:0]  wb_mux;

        Writeback writeback_stage(
                .alu_out(alu_out_wb),
                .data_in(data_in),
                .wb_mux(wb_mux),
                .rd_data(rd_data)
        );

                //wire [31:0] rd_data;

endmodule
