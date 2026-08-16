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

    modport CHECK_MP (
    input clock,
    input reset,

    input write_en,
    input read_en,
    input write_data,

    input read_data,
    input full,
    input empty,
    input valid
    );
endinterface 