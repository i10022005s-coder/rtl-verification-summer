module decoder2to4 (
    input logic [1:0] a,
    output logic [3:0] y1
);
    always_comb begin 
        case (a)
            2'b00: y1 = 4'b0001;
            2'b01: y1 = 4'b0010;
            2'b10: y1 = 4'b0100;
            2'b11: y1 = 4'b1000;
            default: y1 = 4'bxxxx;
        endcase
        
    end
endmodule