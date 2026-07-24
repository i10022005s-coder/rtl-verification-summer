module mips_core (
    input logic clock,
    input logic reset,

    input logic [31:0] instr,
    output logic [31:0] pc,

    output logic [31:0] alu_result,
    output logic [31:0] write_data,
    output logic mem_write,
    input logic [31:0] read_data
);

    logic [5:0] opcode, funct;
    logic mem_to_reg, branch, alu_src, reg_dst, reg_write;
    logic [2:0] alu_control;
    logic zero;
    logic [4:0] shamt;
    logic pc_src;
    assign pc_src = (branch & zero);

    controller controller (
        .opcode (opcode),
        .funct (funct),
    
        .mem_to_reg (mem_to_reg),
        .mem_write (mem_write),
        .branch (branch),
        .alu_src (alu_src),
        .reg_dst (reg_dst),
        .reg_write (reg_write),
        .alu_control (alu_control)
    );
    datapath datapath(
        .clock (clock),
        .reset (reset),

        .mem_to_reg (mem_to_reg),
        .pc_src (pc_src),
        .alu_src (alu_src),
        .reg_dst (reg_dst),
        .reg_write (reg_write),
        .alu_control (alu_control),

        .zero (zero),
        .pc (pc),

        .instr (instr),
        .opcode (opcode),
        .shamt (shamt),
        .funct (funct),

        .alu_result (alu_result),
        .write_data (write_data),
        .read_data (read_data)
    );
    
endmodule