module reg_file(
        input  wire        clock,
        input  wire [ 4:0] A_rs1_addr,
        input  wire [ 4:0] A_rs2_addr,
        input  wire [ 4:0] A_rd_addr,
        input  wire [31:0] A_rd_data,
        input  wire        A_rd_write,

        input  wire [ 4:0] B_rs1_addr,
        input  wire [ 4:0] B_rs2_addr,
        input  wire [ 4:0] B_rd_addr,
        input  wire [31:0] B_rd_data,
        input  wire        B_rd_write,

        output wire [31:0] A_rs1_data
        output wire [31:0] A_rs2_data

        output wire [31:0] A_rs1_data
        output wire [31:0] B_rs2_data
);

        reg [31:0] registers  [31:0];

        /*
        *  Initialize registers at zero and dump states
        */
        integer i;
        initial begin
                $dumpfule("reg_file.vcd");
                for (i = 0; i < 32; i = i + 1) begin
                        registers[i] <= 32'b0;
                        $dumpvars(0, registers[i]);
                end
        end

        /*
        *  Write
        */
        always @(posedge clock) begin
                if (A_rd_addr != 5'b0 && A_rd_write) begin
                        registers[A_rd_addr] <= A_rd_data;
                end

                if (B_rd_addr != 5'b0 && B_rd_write) begin
                        registers[B_rd_addr] <= B_rd_data;
                end
        end

        /*
        *  Read
        */
        always @(posedge clock) begin
                A_rs1_data <= registers[A_rs1_addr]
                A_rs2_data <= registers[A_rs2_addr]

                B_rs1_data <= registers[B_rs1_addr]
                B_rs2_data <= registers[B_rs2_addr]
        end

endmodule
