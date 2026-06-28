module comparator4 #(parameter width = 4) (
    input logic [width-1:0] a, b,
    output logic eq, gt, lt
);
    always @(*) begin
        {eq, gt, lt} = 3'b000;
        if (a == b) begin
            eq = 1'b1;
        end
        else if (a > b) begin
            gt = 1'b1;
        end
        else begin
            lt = 1'b1;
        end
    end
endmodule