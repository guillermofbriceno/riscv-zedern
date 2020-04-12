`include "cpu.v"
`include "components.v"

module computer(
                input clk,
                //output wire clk,
                //output wire [7:0] instruction,
                //output wire [7:0] address_inst_out_led,
                //output wire [7:0] address_inst_out_mcu,
                output wire [7:0] leds
        );
        
        wire write;
        wire [31:0] instruction;
        reg  [31:0] data_in;
        wire [31:0] data_out;
        wire [ 9:0] instruction_address;
        wire [ 9:0] data_address;
        wire [3:0 ] width;
        wire [31:0] inst_mem_data;
        wire [31:0] data_mem_data;
        //wire [07:0] leds;
        //wire clk;

        //assign address_inst_out_led = instruction_address[9:2];
        //assign address_inst_out_mcu = instruction_address[9:2];

        RV32I_CPU CPU(
                .clk(clk), 
                .instruction(instruction),
                .data_in(data_in),
                .data_out(data_out),
                .width(width),
                .write_mem(write),
                .instruction_address(instruction_address),
                .data_address(data_address)
        );

        InstructionMemory BOOTROM(
                .clk(clk),
                .address_p1(instruction_address),
                .address_p2(data_address),
                .data_out_p1(instruction),
                .data_out_p2(inst_mem_data)
        );

        DataMemory DATAMEM(
                .clk(clk),
                .address(data_address),
                .data_in(data_out),
                .width(width),
                .write(write),
                .data_out(data_mem_data)
        );

        GPOPeriph LEDS(
                .clk(clk),
                .address(data_address),
                .data(data_out),
                .write(write),
                .out(leds)
        );

        always @(*) begin
                case (data_address[9])
                        1'b0: data_in <= inst_mem_data;
                        1'b1: data_in <= data_mem_data;
                endcase
        end

        //can use 23 for slow clk
        //clock_gen #(0) CLKGEN(
        //        .in_clk(hwclk),
        //        .out_clk(clk)
        //);


endmodule
