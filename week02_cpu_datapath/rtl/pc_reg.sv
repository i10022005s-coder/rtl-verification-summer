module pc_reg (
    input logic clock,
    input logic reset,
    input logic [31:0] next_pc,
    output logic [31:0] pc
);

    always_ff @(posedge clock or posedge reset) begin 
        if (reset) begin
            pc <= '0;
        end
        else begin
            pc <= next_pc;
        end
    end
    
endmodule