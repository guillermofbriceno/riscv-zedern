`include "pll.v"
`include "defs.v"

module charset_memory(
        input             clk,
        input             enable,
        input  wire [9:0] addr,
        output reg [7:0] row
);
        reg    [7:0] memory [1023:0];
        
        always @ (posedge clk) begin
                if (enable) begin
                        row <= memory[addr];
                end
        end

        initial begin
                $readmemh("/home/guillermo/programming/vga/font/font.h", memory);
        end
endmodule

module text(
        input              clk,
        input              enable,
        input  wire [12:0] addr,
        output reg [7:0]   char
);
        reg    [7:0] memory [8191:0];
        //reg    [12:0] address_reg;

        always @ (posedge clk) begin
                if (enable) begin
                        char <= memory[addr];
                end
                //char <= memory[addr];
        end

        initial begin
                $readmemh("/home/guillermo/programming/vga/text.h", memory);
        end
endmodule

module top(
        input clk,
        output wire hsync,
        output wire vsync,
        output  wire red,
        output  wire green,
        output  wire blue
        );							

        wire [7:0] char;
        wire [7:0] row;
        wire [7:0] row_rev;
        reg  [12:0] addr_text = 0;
        reg  [9:0] addr = 0;

        wire valid;

        reg  [10:0] x = 0;
        wire [10:0] x_buff;
        assign x_buff = x - 2;
        reg  [10:0] y = 0;
        wire [10:0] y_buff;
        assign y_buff = y - 3;
        reg white = 0;

        assign red   = white;
        assign green = white;
        assign blue  = white;
        

        assign hsync = (x <= (`H_VIS+`H_FP)) || (x >= (`H_VIS+`H_FP+`H_SP));
        assign vsync = (y <= (`V_VIS+`V_FP)) || (y >= (`V_VIS+`V_FP+`V_SP));

        assign valid = (x_buff < (`H_VIS+`H_FP)) && (y_buff < (`V_VIS+`V_FP));

        wire       sysclk;							
        wire       locked;							
        pll myPLL (.clock_in(clk), .clock_out(sysclk), .locked(locked));	

        always @ (posedge sysclk) begin
                if (!locked) begin
                        x <= 0;
                        y <= 0;
                end else if (x < `H_TOT) begin
                        x <= x + 1;
                end else begin
                        x <= 0;
                        if (y < `V_TOT) begin
                                y <= y + 1;
                        end else begin
                                y <= 0;
                        end
                end

                addr      <= (char << 3) | y_buff[2:0];
                addr_text <= {5'b0, x_buff[10:3]} + ({5'b0, y_buff[10:3]} * 13'h64);
        end

        always @ (*) begin
                if (valid) begin
                        white <= row[x_buff[2:0]-4];
                end else begin
                        white <= 0;
                end
        end

        charset_memory char_mem(
                .clk(sysclk),
                .enable(valid),
                .addr(addr),
                .row(row)
        );

        text text_mem(
                .clk(sysclk),
                .enable(valid),
                .addr(addr_text),
                .char(char)
        );
endmodule
