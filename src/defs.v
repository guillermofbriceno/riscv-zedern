//   UJ:   0000000000000000000000000_1111111
//   R:    1111111_0000000000_111_00000_1111111
//   ISBU: 00000000000000000_111_00000_1111111

`define UJ_MASK         32'h0000007f
`define R_MASK          32'hfe00707f
`define ISB_MASK        32'h0000707f


`define LUI_OP          32'h00000037
`define AUIPC_OP        32'h00000017
`define JAL_OP          32'h0000006f

`define JALR_OP         32'h00000067
`define BEQ_OP          32'h00000063
`define BNE_OP          32'h00001063
`define BLT_OP          32'h00004063
`define BGE_OP          32'h00005063
`define BLTU_OP         32'h00006063
`define BGEU_OP         32'h00007063
`define LB_OP           32'h00000003
`define LH_OP           32'h00001003
`define LW_OP           32'h00002003
`define LBU_OP          32'h00004003
`define LHU_OP          32'h00005003
`define SB_OP           32'h00000023
`define SH_OP           32'h00001023
`define SW_OP           32'h00002023
`define ADDI_OP         32'h00000013
`define SLTI_OP         32'h00002013
`define SLTIU_OP        32'h00003013
`define XORI_OP         32'h00004013
`define ORI_OP          32'h00006013
`define ANDI_OP         32'h00007013

`define SLLI_OP         32'h00001013
`define SRLI_OP         32'h00005013
`define SRAI_OP         32'h40005013
`define ADD_OP          32'h00000033
`define SUB_OP          32'h40000033
`define SLL_OP          32'h00001033
`define SLT_OP          32'h00002033
`define SLTU_OP         32'h00003033
`define XOR_OP          32'h00004033
`define SRL_OP          32'h00005033
`define SRA_OP          32'h40005033
`define OR_OP           32'h00006033
`define AND_OP          32'h00007033

//`define FENCE_OP        
//`define FENCEI_OP        
//`define ECALL_OP        
//`define EBREAK_OP        
//`define CSRRW_OP        
//`define CSRRS_OP        
//`define CSRRC_OP        
//`define CSRRWI_OP        
//`define CSRRSI_OP        
//`define CSRRCI_OP        

`define LUI_IDX         0
`define AUIPC_IDX       1
`define LODS_IDX        2
`define STRS_IDX        3
`define ALUI_IDX        4
`define SHFI_IDX        5
`define ALUR_IDX        6
`define BRCH_IDX        7
`define JAL_IDX         8
`define JALR_IDX        9

`define LUI             12'h001
`define AUIPC           12'h002
`define LODS            12'h004
`define STRS            12'h008
`define ALUI            12'h010
`define SHFI            12'h020
`define ALUR            12'h040
`define BRCH            12'h080
`define JAL             12'h100
`define JALR            12'h200

//                          B A98 7 6 5 43 21 0     
`define LUI_CTRL        12'b0_000_0_0_1_00_00_0
`define AUIPC_CTRL      12'b0_000_0_0_1_00_11_0
`define LODS_CTRL       12'b0_000_0_0_0_10_10_1
`define STRS_CTRL       12'b1_000_0_0_0_00_01_1
`define ALUI_CTRL       12'b0_000_0_1_1_00_10_1
`define ALUR_CTRL       12'b0_000_1_1_1_00_00_1
`define LODS_CTRL       12'b0_000_0_0_1_10_10_1
`define NOP             12'b0_000_0_0_0_00_00_0
`define BRCH_CTRL       12'b0_001_0_0_0_00_00_1
`define JAL_CTRL        12'b0_010_0_0_1_01_00_0
`define JALR_CTRL       12'b0_100_0_0_1_01_00_0 //Implementation not verified


// Control signal indexes
`define ALU_SRC1_MUX    0:0
`define U_IMM_SEL       0
`define RS1_SEL         1

`define ALU_SRC2_MUX    2:1
`define RS2_SEL         0
`define S_IMM_SEL       1
`define I_IMM_SEL       2
`define PC_SEL          3

`define WRB_REGF_MUX    4:3
`define ALUOUT_SEL      0
`define PC_P_4_SEL      1
`define DTAMEM_SEL      2

`define REGWRITE_SIG    5:5

`define ALU_FUNC_MUX    6:6
`define ADD_SEL         0
`define FUNC_SEL        1

`define ALU_FWIDE_MUX   7:7
`define FUNCT7_DIS      0
`define FUNCT7_SEL      1

`define BRANCH_ENC      10:8
`define NO_BRANCH_SEL   4'b0000
`define JAL_SEL         4'b0100
`define JALR_SEL        4'b1000
`define COND_BR_SEL     4'b0011
`define COND_BR_IDX     8

`define MEMWRITE_SIG    11:11


//Condition Indexes
`define EQ_IDX          0
`define LTS_IDX         1
`define LTU_IDX         2

`define BEQ             3'b000
`define BNE             3'b001
`define BLT             3'b100
`define BGE             3'b101
`define BLTU            3'b110
`define BGEU            3'b111


//Load Types
`define LB              3'b000
`define LH              3'b001
`define LBU             3'b100
`define LHU             3'b101

