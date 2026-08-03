package fifo_transaction_pkg;

    class fifo_transaction;

        bit write_en;
        bit read_en;
        bit [7:0] write_data;

        function new();
            write_en = 1'b0;
            read_en = 1'b0;
            write_data = '0;
        endfunction

        function void generate_random();
            write_en   = $urandom_range(1, 0);
            read_en    = $urandom_range(1, 0);
            write_data = $urandom_range(255, 0);
        endfunction

        function void print(string prefix = "TRANSACTION");
            $display("%s:  write_en = %0b, read_en = %0b write_data = 0x%02h", prefix, write_en, read_en, write_data); 
        endfunction
    endclass 
endpackage