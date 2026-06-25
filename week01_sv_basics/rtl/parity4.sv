module parity4 (
    input logic [3:0] d,
    output logic y
);

assign y= ^d;
endmodule