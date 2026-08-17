module controller (
    input logic [5:0] opcode,
    input logic [5:0] funct,
    
    output logic mem_to_reg,
    output logic mem_write,
    output logic branch,
    output logic alu_src,
    output logic reg_dst,
    output logic reg_write,
    output logic [2:0] alu_control
);

    logic [1:0] alu_op;

    main_decoder u_main_decoder (
        .opcode      (opcode),
        .mem_to_reg  (mem_to_reg),
        .mem_write   (mem_write),
        .branch      (branch),
        .alu_src     (alu_src),
        .reg_dst     (reg_dst),
        .reg_write   (reg_write),
        .alu_op      (alu_op)
    );

    alu_decoder u_alu_decoder (
        .funct       (funct),
        .alu_op      (alu_op),
        .alu_control (alu_control)
    );
    
endmodule