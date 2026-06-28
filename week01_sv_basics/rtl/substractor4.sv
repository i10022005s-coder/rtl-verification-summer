module substractor4 #(parameter width = 4) (
    input logic [width-1:0] a, b,
    output logic [width-1:0] diff,
    output logic borrow
);
    always @(*) begin
        diff = a - b;
        borrow = 1'b0;
        if (a < b) begin
            borrow = 1'b1;
        end
        else begin
            borrow = 1'b0;
        end
    end
endmodule