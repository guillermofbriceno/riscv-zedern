`include "cpu.v"

module computer(
                input hwclk,
                output wire clk,
                output wire [31:0] instruction
        );
        
        wire [31:0] data_in;
        wire [31:0] data_out;
        wire [31:0] address_instruction;
        wire [31:0] address_data;
        reg write = 0;

        Cpu CPU(
                .clk(clk), 
                .instruction(instruction),
                .data_in(data_in),
                .data_out(data_out),
                .address_instruction(address_instruction),
                .address_data(address_data)
        );

        MemoryUnit BootROM(
                .clk(clk),
                .address(address_instruction),
                .data_in(data_out),
                .write(write),
                .data_out(instruction)
        );

        MemoryUnit DATAMEM(
                .clk(clk),
                .address(address_data),
                .data_in(data_out),
                .write(write),
                .data_out(data_in)

        );

        clock_gen #(23) CLKGEN(
                .in_clk(hwclk),
                .out_clk(clk)
        );


endmodule
