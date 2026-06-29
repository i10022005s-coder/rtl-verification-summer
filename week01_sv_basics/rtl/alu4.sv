module alu4 #(parameter width = 4) (
    input logic [width-1:0] a, b,
    input logic [3:0] op,
    output logic [width-1:0] result,
    output logic carry, overflow, zero
);
    logic [4:0] tmp;
    always @(*) begin
        result = '0;
        carry = 1'b0;
        zero = 1'b0;
        overflow = 1'b0;
        case (op)
            4'b0000: begin //ADD
                tmp = a + b;
                result = tmp[3:0];
                carry = tmp[4];
                overflow = (~(a[3] ^ b[3])) & (result[3] ^ a[3]);
            end
            4'b0001: begin //SUB
                result = a - b;
                carry = (a < b);
                overflow = (a[3] ^ b[3]) & (result[3] ^ a[3]);
                zero = (result == 4'b0000);
            end
            4'b0010: begin //AND
                result = a & b;
            end
            4'b0011: begin //OR
                result = a | b;
            end
            4'b0100: begin //XOR
                result = a ^ b;
            end 
            4'b0101: begin //SLT
                result = ($signed(a) < $signed(b)) ? 'b0001 : '0;
            end 
            4'b0110: begin //SLTU
                result = (a < b) ? 'b0001 : '0;
            end
            4'b0111: begin //SLL
                result = a << 1;
            end
            4'b1000: begin //SRL
                result = a >> 1;
            end
            4'b1001: begin //SRA
                result = $signed(a) >>> 1;
            end
            default: begin
                result = '0;
            end
        endcase
    end
    
endmodule