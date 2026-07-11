module reg_file #(
    parameter int DATA_WIDTH = 32,
    parameter int ADDR_WIDTH = 5
) (
    input logic clock,
    input logic reset,

    input logic we,

    input logic [ADDR_WIDTH-1:0] ra1,
    input logic [ADDR_WIDTH-1:0] ra2,
    input logic [ADDR_WIDTH-1:0] wa,

    input logic [DATA_WIDTH-1:0] wd,

    output logic [DATA_WIDTH-1:0] rd1,
    output logic [DATA_WIDTH-1:0] rd2
);

    localparam int NUM_REGS = 1 << ADDR_WIDTH;

    logic [DATA_WIDTH-1:0] regs [NUM_REGS-1:0];

    assign rd1 = (ra1 == '0) ? '0 : regs[ra1];
    assign rd2 = (ra2 == '0) ? '0 : regs[ra2];

    always_ff @(posedge clock or posedge reset) begin
        if (reset) begin
            for (int i = 0; i < NUM_REGS; i++) begin
                regs[i] = '0;
            end
        end
        else begin
            if (we) begin
                regs[wa] <= wd;
            end
        end
    end

    
endmodule