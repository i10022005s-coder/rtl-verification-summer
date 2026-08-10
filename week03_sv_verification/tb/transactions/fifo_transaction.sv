package fifo_transaction_pkg;

    class fifo_transaction #(
        parameter  int DATA_WIDTH = 8
    );;

        bit write_en;
        bit read_en;
        bit [DATA_WIDTH-1:0] write_data;

        logic [DATA_WIDTH-1:0] read_data;
        logic empty;
        logic full;
        logic valid;

        int unsigned id;

        function new();
            write_en = 1'b0;
            read_en = 1'b0;
            write_data = '0;
            empty = 1'b0;
            full = 1'b0;
            valid = 1'b0;
            read_data = '0;
            id = 0;
        endfunction

        function void generate_random();
            write_en   = $urandom_range(1, 0);
            read_en    = $urandom_range(1, 0);
            write_data = $urandom_range(255, 0);
        endfunction

        function void print(string prefix = "TRANSACTION");
            $display("%s:  id = %0d, write_en = %0b, read_en = %0b write_data = 0x%02h", prefix, id, write_en, read_en, write_data); 
        endfunction
    endclass 
endpackage