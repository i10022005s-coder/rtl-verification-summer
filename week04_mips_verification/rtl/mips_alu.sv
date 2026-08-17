module mips_alu (
    input logic [31:0] a,
    input logic [31:0] b,
    input logic [2:0] alu_control,

    output logic [31:0] result,
    output logic zero
);  

    localparam logic [2:0] AND = 3'b000;
    localparam logic [2:0] OR = 3'b001;
    localparam logic [2:0] ADD = 3'b010;
    localparam logic [2:0] SUB = 3'b110;
    localparam logic [2:0] SLT = 3'b111;

    always @(*) begin
        result = '0;
        case (alu_control)
            AND : result = a & b;
            OR : result = a | b;
            ADD : result = a + b;
            SUB : result = a - b;
            SLT : result = ($signed(a) < $signed(b)) ? 32'b1 : 32'b0;
            default: result = '0;
        endcase
    end
    assign zero = (result == '0);

endmodule