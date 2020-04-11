
module Fetch(
        input clk,
        output wire [9:0] instruction_address
        //output reg [31:0] pc;
);
        reg [31:0] pc = 32'h114;
        wire [31:0] pc_next;

        assign pc_next             = pc + 4;
        assign instruction_address = pc[9:0];

        always @ (posedge clk) begin
                pc <= pc_next;
        end
endmodule
