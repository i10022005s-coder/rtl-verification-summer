module mux2 #(
    parameter int WIDTH = 32
) (
    input logic [WIDTH-1:0] d0,
    input logic [WIDTH-1:0] d1,
    input logic select,
    output logic [WIDTH-1:0] result
);
    
    assign result = (select == 1'b0) ? d0 : d1;

endmodule