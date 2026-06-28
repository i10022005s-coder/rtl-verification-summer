module full_adder (
    input logic a, b, cin,
    output logic summ, cout
);
    assign summ = a ^ b ^ cin;
    assign cout = (a & b) | (cin & b) | (a & cin);
endmodule