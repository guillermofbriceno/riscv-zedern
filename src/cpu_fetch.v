
module Fetch(
        input clk,
        input stall,
        output wire [9:0] instruction_address,
        output reg [31:0] pc_out,

        input [31:0] target,
        input [0:0]  taken,
        input [31:0] instruction_in,
        input flush,
        output reg [31:0] instruction_out
);
        reg [31:0] pc_next;
        reg [31:0] pc;

        initial begin 
                pc              <= 32'h00000314;
                pc_out          <= 32'h0000314;
                instruction_out <= 32'b0;

        end

        assign instruction_address = pc[9:0];

        always @ (posedge clk) begin
                if (!stall) begin
                        pc <= pc_next;
                        //pc_out_fe2 <= pc;
                        pc_out <= pc;
                end
        end

        //always @ (posedge clk) begin
        //        if (!flush) begin
        //                if (!stall) begin
        //                        pc_out <= pc_out_fe2;
        //                        instruction_out <= instruction_in;
        //                end
        //        end else begin
        //                instruction_out <= 32'b0;
        //                pc_out <= 32'b0;
        //        end
        //end

        always @ (*) begin
                if (taken) begin
                        pc_next <= target;
                end else begin
                        pc_next <= pc + 4;
                end
                instruction_out <= instruction_in;
        end
endmodule
