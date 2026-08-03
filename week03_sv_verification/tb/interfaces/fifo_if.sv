interface fifo_if #(
    parameter int DATA_WIDTH = 8
) (
    input logic clock
);
    
    logic reset;
    logic write_en;
    logic read_en;
    logic [DATA_WIDTH-1:0] write_data;

    logic [DATA_WIDTH-1:0] read_data;
    logic full;
    logic empty;
    logic valid;

endinterface 