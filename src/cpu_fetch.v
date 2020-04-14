
module Fetch(
        input clk,
        input stall,
        output wire [9:0] instruction_address,
        output reg [31:0] pc_out,

        input [31:0] target,
        input [0:0]  taken
);
        reg [31:0] pc_next;
        reg [31:0] pc = 32'b00;

        assign instruction_address = pc[9:0];

        always @ (posedge clk) begin
                if (!stall) begin
                        pc <= pc_next;
                end
                pc_out <= pc;
        end

        always @ (*) begin
                if (taken) begin
                        pc_next <= target;
                end else begin
                        pc_next <= pc + 4;
                end
        end
endmodule
