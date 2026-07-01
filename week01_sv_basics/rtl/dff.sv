module dff #(parameter int width = 1) (
    input logic [width-1:0] d,
    input logic clock,
    input logic reset,
    output logic [width-1:0] q
);
    always_ff @(posedge clock,  posedge reset) begin 
        if (reset) begin
            q <= '0;
        end
        else begin
            q <= d;
        end
    end
endmodule