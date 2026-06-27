module comparator4 (
    input logic [3:0] a,
    input logic [3:0] b,
    input logic eqin,
    input logic gtin,
    input logic ltin,
    output logic eqout,
    output logic gtout,
    output logic ltout
);

    always @(*) begin
        eqout = 1'b0;
        gtout = 1'b0;
        ltout = 1'b0;

        if (a == b) begin
            if (eqin) begin
                eqout = 1'b1;
            end
            else if (gtin) begin
                gtout = 1'b1;
            end
            else if (ltin) begin
                ltout = 1'b1;
            end
            else begin
                eqout = 1'b1;
            end
        end
        else if (a > b) begin
            gtout = 1'b1;
        end
        else if (a < b) begin
            ltout = 1'b1;
        end
    end    
endmodule