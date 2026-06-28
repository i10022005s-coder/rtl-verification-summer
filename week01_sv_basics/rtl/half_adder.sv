module half_adder (
    input logic a,
    input logic b,
    output logic summ,
    output logic carry
);
    assign summ = a ^ b;
    assign cout = a & b;
endmodule