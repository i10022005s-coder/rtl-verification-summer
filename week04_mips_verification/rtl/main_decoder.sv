module main_decoder (
    input logic [5:0] opcode,
    
    output logic mem_to_reg,
    output logic mem_write,
    output logic branch,
    output logic alu_src,
    output logic reg_dst,
    output logic reg_write,

    output logic [1:0] alu_op
);

    localparam logic [5:0] OP_R_TYPE = 6'b000000;
    localparam logic [5:0] OP_LW = 6'b100011;
    localparam logic [5:0] OP_SW = 6'b101011;
    localparam logic [5:0] OP_BEQ = 6'b000100;
    localparam logic [5:0] OP_ADDI = 6'b001000;

    always @(*) begin
        mem_to_reg = 1'b0;
        mem_write = 1'b0;
        branch = 1'b0;
        alu_src = 1'b0;
        reg_dst = 1'b0;
        reg_write = 1'b0;
        alu_op = 2'b00;

        case (opcode)
            OP_R_TYPE : begin
                reg_dst = 1'b1;
                reg_write = 1'b1;
                alu_op = 2'b10;
            end
            OP_LW : begin
                mem_to_reg = 1'b1;
                alu_src = 1'b1;
                reg_write = 1'b1;
            end
            OP_SW : begin
                mem_write = 1'b1;
                alu_src = 1'b1;
            end
            OP_BEQ : begin
                branch = 1'b1;
                alu_op = 2'b01;
            end
            OP_ADDI: begin
                alu_src   = 1'b1;
                reg_write = 1'b1;
            end
            default: begin
                mem_to_reg = 1'b0;
                mem_write = 1'b0;
                branch = 1'b0;
                alu_src = 1'b0;
                reg_dst = 1'b0;
                reg_write = 1'b0;
                alu_op = 2'b00;
            end
        endcase
    end
    
endmodule