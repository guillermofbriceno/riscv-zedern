`include "cpu.v"

module computer(
                input clk,
                //output wire clk,
                //output wire [7:0] instruction,
                output wire [7:0] address_inst_out_led,
                //output wire [7:0] address_inst_out_mcu,
                //output wire [7:0] leds
        );
        
        wire write;
        reg  [31:0] data_in;
        wire [31:0] data_out;
        wire [ 9:0] address_instruction;
        wire [ 9:0] address_data;
        wire [3:0 ] width;
        wire [31:0] inst_mem_data;
        wire [31:0] data_mem_data;
        wire [31:0] instruction;
        //wire clk;

        assign address_inst_out_led = address_instruction[9:2];
        //assign address_inst_out_mcu = address_instruction[9:2];

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

        InstructionMemory BOOTROM(
                .clk(clk),
                .address_p1(address_instruction),
                .address_p2(address_data),
                .data_out_p1(instruction),
                .data_out_p2(inst_mem_data)
        );

        DataMemory DATAMEM(
                .clk(clk),
                .address(address_data),
                .data_in(data_out),
                .width(width),
                .write(write),
                .data_out(data_mem_data)
        );

        //GPOPeriph LEDS(
        //        .clk(clk),
        //        .address(address_data),
        //        .data(data_out),
        //        .write(write),
        //        .out(leds)
        //);

        always @(*) begin
                case (address_data[9])
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
