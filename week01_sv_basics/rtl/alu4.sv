module alu4 #(parameter width = 4) (
    input logic [width-1:0] a, b,
    input logic [3:0] op,
    output logic [width-1:0] result,
    output logic carry, overflow, zero
);

    localparam logic [3:0] ALU_ADD  = 4'b0000;
    localparam logic [3:0] ALU_SUB  = 4'b0001;
    localparam logic [3:0] ALU_AND  = 4'b0010;
    localparam logic [3:0] ALU_OR   = 4'b0011;
    localparam logic [3:0] ALU_XOR  = 4'b0100;
    localparam logic [3:0] ALU_SLT  = 4'b0101;
    localparam logic [3:0] ALU_SLTU = 4'b0110;
    localparam logic [3:0] ALU_SLL  = 4'b0111;
    localparam logic [3:0] ALU_SRL  = 4'b1000;
    localparam logic [3:0] ALU_SRA  = 4'b1001;

    logic [width:0] tmp;
    always @(*) begin
        result = '0;
        carry = 1'b0;
        zero = 1'b0;
        overflow = 1'b0;
        case (op)
            ALU_ADD: begin //ADD
                tmp = a + b;
                result = tmp[width-1:0];
                carry = tmp[width];
                overflow = (~(a[width-1] ^ b[width-1])) & (result[width-1] ^ a[width-1]);
            end
            ALU_SUB: begin //SUB
                result = a - b;
                carry = (a < b);
                overflow = (a[width-1] ^ b[width-1]) & (result[width-1] ^ a[width-1]);
            end
            ALU_AND: begin //AND
                result = a & b;
            end
            ALU_OR: begin //OR
                result = a | b;
            end
            ALU_XOR: begin //XOR
                result = a ^ b;
            end 
            ALU_SLT: begin //SLT
                result = ($signed(a) < $signed(b)) ? 'b0001 : '0;
            end 
            ALU_SLTU: begin //SLTU
                result = (a < b) ? 'b0001 : '0;
            end
            ALU_SLL: begin //SLL
                result = a << 1;
            end
            ALU_SRL: begin //SRL
                result = a >> 1;
            end
            ALU_SRA: begin //SRA
                result = $signed(a) >>> 1;
            end
            default: begin
                result = '0;
            end
        endcase
        zero = (result == '0);
    end
    
endmodule