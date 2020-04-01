`include "cpu.v"

module cpu_tb();
        
        reg clk = 0;
        wire [31:0] instruction;
        wire [31:0] data_in;
        wire [31:0] data_out;
        wire [31:0] address_instruction;
        wire [31:0] address_data;
        wire [31:0] inst_data_out = 32'b0;
        wire [1:0] width;
        wire write;
        reg empty_write = 0;
        integer i = 0;

        Cpu CPU(
                .clk(clk), 
                .instruction(instruction),
                .data_in(data_in),
                .data_out(data_out),
                .width(width),
                .write_mem(write),
                .address_instruction(address_instruction),
                .address_data(address_data)
        );

        MemoryUnit BootROM(
                .clk(clk),
                .address(address_instruction),
                .data_in(inst_data_out),
                .write(empty_write),
                .data_out(instruction)
        );

        DataMemory DATAMEM(
                .clk(clk),
                //.address(address_data),
                .address(address_data),
                .data_in(data_out),
                .width(width),
                .write(write),
                .data_out(data_in)
        );

        initial begin
                $dumpfile("cpu_test.vcd");
                $dumpvars(0, CPU);
                $dumpvars(0, BootROM);
                $dumpvars(0, DATAMEM);
                #1;
                for (i=0; i < 10; i=i+1) begin
                        clk = 1;
                        #1;
                        clk = 0;
                        #1;
                end

                #20

                $finish;
        end
endmodule
