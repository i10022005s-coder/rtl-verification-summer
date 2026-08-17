module instruction_decoder (
    input logic [31:0] instr,

    output logic [5:0] opcode,
    output logic [4:0] rs,
    output logic [4:0] rt,
    output logic [4:0] rd,
    output logic [4:0] shamt,
    output logic [5:0] funct,

    output logic [31:0] extended_imm
);
    
    logic [15:0] imm;

    assign opcode = instr [31:26];
    assign rs = instr [25:21];
    assign rt = instr [20:16];
    assign rd = instr [15:11];
    assign shamt = instr [10:6];
    assign funct = instr [5:0];
    assign imm = instr [15:0];

    assign extended_imm =
    ((opcode == 6'h0C) ||
     (opcode == 6'h0D) ||
     (opcode == 6'h0E))
    ? {16'b0, imm}
    : {{16{imm[15]}}, imm};


endmodule