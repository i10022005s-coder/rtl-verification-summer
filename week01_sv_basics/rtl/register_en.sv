module register_en #(parameter int width = 4) (
    input logic [width-1:0] d,
    input logic clock,
    input logic reset,
    input logic enable,
    output logic [width-1:0] q
);
    always_ff @(posedge clock,  posedge reset) begin 
        if (reset) begin
            q <= '0;
        end
        else if (enable) begin
            q <= d;
        end
    end
endmodule