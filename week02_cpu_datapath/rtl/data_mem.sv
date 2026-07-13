module data_mem #(
    parameter int DATA_WIDTH = 32,
    parameter int DEPTH = 64
) (
    input logic clock,
    input logic we,
    input logic [31:0] addr,
    input logic [DATA_WIDTH-1:0] wd,
    output logic [DATA_WIDTH-1:0] rd
);
    localparam int INDEX_WIDTH = $clog2(DEPTH);

    logic [INDEX_WIDTH-1:0] word_index;
    assign word_index = addr[INDEX_WIDTH+1:2];

    logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    assign rd = mem[word_index];

    always_ff @(posedge clock) begin
        if (we) begin
            mem[word_index] <= wd;
        end
    end

endmodule