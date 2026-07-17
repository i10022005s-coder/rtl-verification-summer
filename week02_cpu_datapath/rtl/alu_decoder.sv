module alu_decoder (
    input logic [5:0] funct,
    input logic [1:0] alu_op,
    
    output logic [2:0] alu_control
);

    localparam logic [1:0] ALUOP_ADD = 2'b00;
    localparam logic [1:0] ALUOP_SUB = 2'b01;
    localparam logic [1:0] ALUOP_R_TYPE = 2'b10;

    always @(*) begin
        alu_control = 3'b000;
        case (alu_op)
            ALUOP_ADD : alu_control = 3'b010;
            ALUOP_SUB : alu_control = 3'b110;
            ALUOP_R_TYPE : begin
                case (funct)
                    6'h20: alu_control = 3'b010; // add
                    6'h22: alu_control = 3'b110; // sub
                    6'h24: alu_control = 3'b000; // and
                    6'h25: alu_control = 3'b001; // or
                    6'h2A: alu_control = 3'b111; // slt
                    default: alu_control = 3'b000;
                endcase
            end
            default: alu_control = 3'b000;
        endcase
    end

endmodule