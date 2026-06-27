module mux4_if (
    input logic [3:0] a,
    input logic [1:0] sel,
    output logic y
);

   always @(*) begin 
        y = 1'b0;
        if (sel == 2'b00) begin
            y = a[0];
        end
        else if (sel == 2'b01) begin
            y = a[1];
        end
        else if (sel == 2'b10) begin
            y = a[2];
        end
        else begin
            y = a[3];
        end
    
   end

endmodule