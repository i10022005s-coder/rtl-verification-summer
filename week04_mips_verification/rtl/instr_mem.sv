module instr_mem #(
    parameter int DATA_WIDTH = 32,
    parameter int DEPTH = 64,
    parameter INIT_FILE = "tb/data/program.hex"
) (
    input logic [31:0] addr,
    output logic [DATA_WIDTH-1:0] instr
);
    localparam int INDEX_WIDTH = $clog2(DEPTH);
    logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    initial begin
        $readmemh(INIT_FILE, mem);
    end

    assign instr = mem[addr[INDEX_WIDTH+1:2]];
endmodule