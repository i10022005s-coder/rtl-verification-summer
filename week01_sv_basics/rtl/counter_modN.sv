module counter_modN #(parameter int width = 4, parameter int N = 10) (
    input logic clock,
    input logic reset,
    input logic enable,
    output logic [width-1:0] count
);
    always_ff @(posedge clock,  posedge reset) begin 
        if (reset) begin
            count <= '0;
        end
        else if (enable) begin
            if (count == N-1) begin
                count <= '0;
            end
            else begin
                count <= count + 1'b1;
            end
        end
    end
endmodule