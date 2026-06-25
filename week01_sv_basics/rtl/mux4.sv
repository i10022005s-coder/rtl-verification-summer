module mux4 (
    input logic [3:0] d2,
    input logic [1:0] sel,
    output logic y2
);
    always @(*) begin 
        if (sel[1] & sel[0]) y2 = d2[3];
        else if (sel[1] & ~sel[0]) y2 = d2[2];
        else if (~sel[1] & sel[0]) y2 = d2[1];
        else if (~(sel[1] | sel[0])) y2 = d2[0];
        
    end
endmodule    