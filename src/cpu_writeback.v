module Writeback(
        input   wire [31:0]  alu_out,
        input   wire [31:0]  data_in,
        //input   wire [31:0]  pc,
        //input   wire [2:0]  funct3,
        input   wire [01:0]  wb_mux,

        output  reg  [31:0]  rd_data
);

        reg [2:0] funct3 = 3'b0; //temp
        reg [31:0] pc = 32'b0; //temp
        reg [31:0] adjusted_data_in;

        always @ (*) begin
                case(funct3)
                        `LB:     adjusted_data_in <= {{24{data_in[7]}}, data_in[7:0]};
                        `LH:     adjusted_data_in <= {{16{data_in[15]}}, data_in[15:0]};
                        `LBU:    adjusted_data_in <= {24'b0, data_in[7:0]};
                        `LHU:    adjusted_data_in <= {16'b0, data_in[15:0]};
                        default: adjusted_data_in <= data_in;
                endcase

                case(wb_mux)
                        `ALUOUT_SEL: rd_data <= alu_out;
                        `PC_P_4_SEL: rd_data <= pc+4;
                        `DTAMEM_SEL: rd_data <= adjusted_data_in;
                        default:     rd_data <= alu_out;
                endcase
        end
endmodule
