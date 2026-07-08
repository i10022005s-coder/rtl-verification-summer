module sync_fifo #(
    parameter int WIDTH = 8, 
    parameter int DEPTH = 8
    ) (
    input logic clock,
    input logic reset,

    input logic write_en,
    input logic read_en,

    input logic [WIDTH-1:0] wdata,
    output logic [WIDTH-1:0] rdata,

    output logic valid,
    output logic empty,
    output logic full
);

    logic [WIDTH-1:0] mem [0:DEPTH-1];

    logic [$clog2(DEPTH)-1:0] write_ptr;
    logic [$clog2(DEPTH)-1:0] read_ptr;
    logic [$clog2(DEPTH+1)-1:0] count;

    assign empty = (count === 0);
    assign full = (count === DEPTH);
    
    always_ff @(posedge clock,  posedge reset) begin 
        if (reset) begin
            count <= '0;
            write_ptr <= '0;
            read_ptr <= '0;
            valid <= '0;
        end
        else begin
            valid <= '0;
            if (empty & write_en & read_en) begin
                rdata <= wdata;
                valid <= 1'b1;
            end
            if (read_en & write_en & ~empty & ~full) begin
                rdata <= mem[read_ptr];
                mem[write_ptr] <= wdata;
                read_ptr <= read_ptr + 'b1;
                write_ptr <= write_ptr + 'b1;
                valid <= 1'b1;
            end
            if (read_en & ~write_en & ~empty) begin
                rdata <= mem[read_ptr];
                read_ptr <= read_ptr + 'b1;
                count <= count - 'b1;
                valid <= 1'b1;
            end    
            if (~read_en & write_en & ~full) begin
                mem[write_ptr] <= wdata;
                write_ptr <= write_ptr + 'b1;
                count <= count + 'b1;
            end         
        end 
    end
    
endmodule