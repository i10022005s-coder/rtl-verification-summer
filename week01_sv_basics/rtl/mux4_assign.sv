module mux4_assign (
    input logic [3:0] a,
    input logic [1:0] sel,
    output logic y
);

    assign y = (sel == 2'b00) ? a[0]:
    (sel == 2'b01) ? a[1]:
    (sel == 2'b10) ? a[2]:
    a[3];

endmodule