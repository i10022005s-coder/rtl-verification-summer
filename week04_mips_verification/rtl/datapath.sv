module datapath (
    input logic clock,
    input logic reset,

    input logic mem_to_reg,
    input logic pc_src,
    input logic alu_src,
    input logic reg_dst,
    input logic reg_write,
    input logic [2:0] alu_control,

    output logic zero,
    output logic [31:0] pc,

    input logic [31:0] instr,
    output logic [5:0] opcode,
    output logic [4:0] shamt,
    output logic [5:0] funct,

    output logic [31:0] alu_result,
    output logic [31:0] write_data,
    input logic [31:0] read_data
);

    logic [4:0] write_reg;
    logic [4:0] rs;
    logic [4:0] rt;
    logic [4:0] rd;

    logic [31:0] rd1;
    logic [31:0] rd2;
    logic [31:0] src_b;
    logic [31:0] result;

    logic [31:0] extended_imm;
    logic [31:0] shifted_imm;

    logic [31:0] pc_plus4;
    logic [31:0] pc_branch;
    logic [31:0] next_pc;

    instruction_decoder instruction_decoder(instr, opcode, rs, rt, rd, shamt, funct, extended_imm);

    //Логика PC
    assign pc_plus4 = pc + 32'd4;
    assign shifted_imm = extended_imm << 2;
    assign pc_branch = pc_plus4 + shifted_imm;
    mux2 #(32) pc_br_mux(pc_plus4, pc_branch, pc_src, next_pc);
    pc_reg pc_reg(clock, reset, next_pc, pc);

    //Выбор регистра назначения
    mux2 #(5) reg_wr_mux(rt, rd, reg_dst, write_reg);
    reg_file reg_file(clock, reset, reg_write, rs, rt, write_reg, result, rd1, rd2);

    //Выбор второго входа АЛУ
    mux2 #(32) in2_alu_mux(rd2, extended_imm, alu_src, src_b);
    mips_alu mips_alu(rd1, src_b, alu_control, alu_result, zero);

    //Выбор записываемого результата
    mux2 #(32) write_reg_mux(alu_result, read_data, mem_to_reg, result);

    assign write_data = rd2;

    
endmodule