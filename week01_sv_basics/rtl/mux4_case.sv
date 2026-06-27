module mux4_case (
    input logic [3:0] a,
    input logic [1:0] sel,
    output logic y
);

   always @(*) begin 
        y = 1'b0;
        case (sel)
            2'b00 : y = a[0]; 
            2'b01 : y = a[1]; 
            2'b10 : y = a[2]; 
            2'b11 : y = a[3]; 
            default: y = 1'b0;
        endcase
    
   end

endmodule