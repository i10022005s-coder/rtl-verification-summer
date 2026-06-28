module adder4 #(parameter width = 4) (
    input logic [width-1:0] a, b,
    input logic cin,
    output logic [width-1:0] summ,
    output logic cout
);
    assign {cout, summ} = a + b + cin;
endmodule