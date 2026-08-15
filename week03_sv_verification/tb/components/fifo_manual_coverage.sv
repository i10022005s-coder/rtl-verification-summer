package fifo_coverage_pkg;
    import fifo_transaction_pkg::*;

    class fifo_coverage;
        mailbox #(fifo_transaction) inbox;
        int unsigned transaction_count;
        int unsigned sampled_count;

        bit write_en, read_en;
        logic full, empty, valid;

        int unsigned op_state_count[4][3];
        int unsigned op, state;

        function new(
            mailbox #(fifo_transaction) inbox,
            int unsigned transaction_count
        );
            this.inbox = inbox;
            this.transaction_count = transaction_count;
            sampled_count = 0;
            for (int i = 0; i < 4; i++) begin
                for (int j = 0; j < 3; j++) begin
                    op_state_count[i][j] = 0;
                end
            end
        endfunction
        
        task run();
            fifo_transaction tr;
            
            repeat (transaction_count) begin
                inbox.get(tr);
                
                write_en = tr.write_en;
                read_en = tr.read_en;
                full = tr.full;
                empty = tr.empty;
                valid = tr.valid;

                case ({write_en, read_en})
                    2'b00 :  op = 0;
                    2'b01 :  op = 1;
                    2'b10 :  op = 2;
                    2'b11 :  op = 3;
                endcase
                if (tr.empty)
                    state = 0;
                else if (tr.full)
                    state = 2;
                else
                    state = 1;
                op_state_count[op][state]++;

                sampled_count++;
            end
        endtask 

        function real get_coverage();
            int unsigned operations = 0;
            for (int i = 0; i < 4; i++) begin
                for (int j = 0; j < 3; j++) begin
                    if (op_state_count[i][j] !== 0) begin
                        operations++;
                    end
                end
            end
            
            return 100.0 * operations / 10.0; 
        endfunction

    endclass 
endpackage