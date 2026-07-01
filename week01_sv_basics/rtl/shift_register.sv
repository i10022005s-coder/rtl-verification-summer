module shift_register #(parameter int width = 4) (
    input logic clock,
    input logic reset,
    input logic enable,
    input logic serial_in,
    output logic [width-1:0] q
);
    always_ff @(posedge clock,  posedge reset) begin 
        if (reset) begin
            q <= 4'b0000;
        end
        else if (enable) begin
            q <= {q[width-2:0], serial_in};
        end
    end
endmodule