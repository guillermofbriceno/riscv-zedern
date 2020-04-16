`include "defs.v"

// System components
module InstructionMemory #(parameter bits_data = 32, bits_addr = 10, entries=1024) (
        input clk,
        //input select_inst,
        //input select_data,
        input stall,
        input [9:0] address_p1,
        //input [9:0] address_p2,
        output wire [31:0] data_out_p1
        //output reg [31:0] data_out_p2
        );
        //reg [31:0] data_out = 32'b0;

        //reg [31:0] data_out_p1_int;
        //reg [31:0] data_out_p2_int;

        //assign data_out_p1 = data_out_p1_int;
        //assign data_out_p2 = data_out_p2_int;

        reg [7:0] memory [1023:0];
        reg [9:0]  address1, address2, address3, address4;
        assign data_out_p1 = {memory[address1], memory[address2], memory[address3], memory[address4]};

        always @ (posedge clk) begin
                if (!stall) begin
                        address1 <= address_p1+3;
                        address2 <= address_p1+2;
                        address3 <= address_p1+1;
                        address4 <= address_p1;
                end
        end


        initial begin
                $readmemh("/home/guillermo/programming/riscv-zedern/scripts/c_image.hex", memory);
                //$readmemh("/home/guillermo/programming/riscv-zedern/scripts/image.hex", memory);
        end

        //always @(posedge clk) begin
        //        if (!stall) begin
        //                data_out <= {memory[address_p1+3], memory[address_p1+2], memory[address_p1+1], memory[address_p1]};
        //        end else begin
        //                data_out <= data_out;
        //        end

        //        //data_out_p2 <= {memory[address_p2+3], memory[address_p2+2], memory[address_p2+1], memory[address_p2]};
        //end


        //always @(posedge clk) begin
        //        if (select_inst) begin
        //                if (!stall) begin
        //                        data_out_p1 <= {memory[address_p1+3], memory[address_p1+2], memory[address_p1+1], memory[address_p1]};
        //                end
        //        end else begin
        //                data_out_p1 <= 32'b0;
        //        end

        //        if (select_data) begin
        //                data_out_p2 <= {memory[address_p2+3], memory[address_p2+2], memory[address_p2+1], memory[address_p2]};
        //        end else begin
        //                data_out_p2 <= 32'b0;
        //        end
        //end
endmodule

module InstructionMemoryController (
        input clk,
        input [9:0] address_p1,
        input [9:0] address_p2,
        output wire [31:0] data_out_inst,
        output wire [31:0] data_out_data,
        input stall,
        input select_inst,
        input select_data
);
        wire [31:0] data_out_p1;
        //wire [31:0] data_out_p2;
        reg [31:0] data_out_p2 = 32'b0;

        reg [31:0] data_out_p1_mask;
        reg [31:0] data_out_p2_mask;

        //reg [31:0] buffer;

        assign data_out_inst = data_out_p1 & data_out_p1_mask;
        assign data_out_data = data_out_p2 & data_out_p2_mask;

        //assign data_out_inst = data_out_p1;
        //assign data_out_data = data_out_p2;
        //always @ (*) begin
        //        if (stall) begin
        //                data_out_inst <= buffer & data_out_p1_mask;
        //        end else begin
        //                data_out_inst <= data_out_p1 & data_out_p1_mask;
        //        end
        //end

        always @ (posedge clk) begin

                if (select_inst) begin
                        data_out_p1_mask <= 32'hFFFFFFFF;
                end else begin
                        data_out_p1_mask <= 32'b0;
                end

                if (select_data) begin
                        data_out_p2_mask <= 32'hFFFFFFFF;
                end else begin
                        data_out_p2_mask <= 32'b0;
                end
        end

        //always @ (*) begin
        //        if (!stall) begin
        //                buffer = data_out_p1;
        //        end
        //end

        
        InstructionMemory INSTMEM(
                .clk(clk),
                .address_p1(address_p1),
                //.address_p2(address_p2),
                .data_out_p1(data_out_p1),
                //.data_out_p2(data_out_p2),
                .stall(stall)
        );


endmodule

module DataMemory #(parameter bits_data = 32, bits_addr = 10, entries=1024) (
        input clk,
        input write,
        input [9:0] address,
        input [31:0] data_in,
        input [3:0] width,
        input select,
        output reg [31:0] data_out
        );

        reg [31:0] memory [1023:0];

        //reg [31:0] memory [:entries - 1];
        integer i;

        initial begin
                $readmemh("/home/guillermo/programming/riscv-zedern/scripts/empty.hex", memory);
                for(i=0; i < 1024; i=i+1) begin
                        $dumpvars(0, memory[i]);
                end
        end

        always @(posedge clk) begin
                data_out <= {memory[address[9:2]][7:0], memory[address[9:2]][15:8], memory[address[9:2]][23:16], memory[address[9:2]][31:24]};

                if (write) begin
                        if (width[3]) begin
                                memory[address[9:2]][7:0] <= data_in[31:24];
                        end
                        if (width[2]) begin
                                memory[address[9:2]][15:8] <= data_in[23:16];
                        end
                        if (width[1]) begin
                                memory[address[9:2]][23:16] <= data_in[15:8];
                        end
                        if (width[0]) begin
                                memory[address[9:2]][31:24] <= data_in[7:0];
                        end
                end
        end
endmodule

module GPOPeriph (address, data, out, clk, write);
        input [9:0] address;
        input [ 7:0] data;
        input        clk;
        input        write;
        output [7:0] out;

        reg [7:0] mem = 8'b0;
        
        always @ (posedge clk) begin
                if (address == 10'h50 & write) begin
                        mem <= data;
                end
        end
        assign out = mem;

endmodule

module clock_gen #(parameter clock_tap = 21)(in_clk, out_clk);
        input in_clk;
        output out_clk;

        reg[clock_tap:0] counter = {clock_tap{1'b0}};
        assign out_clk = counter[clock_tap];

        always @ (posedge in_clk) begin
                counter = counter + 1;
        end
endmodule
