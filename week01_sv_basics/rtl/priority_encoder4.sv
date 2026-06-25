module priority_encoder4 (
    input logic [3:0] d,
    output logic [1:0] y,
    output logic valid
);
    always @(*) begin 
        y = 2'b00;
        valid = 0;
        if (d[3]) begin
            y = 2'b11;
            valid = 1;
        end
        else if (d[2]) begin
            y = 2'b10;
            valid = 1;
        end
        else if (d[1]) begin
            y = 2'b01;
            valid = 1;
        end
        else if (d[0]) begin
            y = 2'b00;
            valid = 1;
        end
    end
endmodule