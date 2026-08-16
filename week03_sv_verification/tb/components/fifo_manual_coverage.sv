package fifo_coverage_pkg;
    import fifo_transaction_pkg::*;

    class fifo_coverage;
        mailbox #(fifo_transaction) inbox;
        int unsigned transaction_count;
        int unsigned sampled_count;

        bit write_en, read_en;
        logic valid;
        logic pre_full, pre_empty;

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

            pre_full = 1'b0;
            pre_empty = 1'b1;
            
            repeat (transaction_count) begin
                inbox.get(tr);
                
                write_en = tr.write_en;
                read_en = tr.read_en;
                valid = tr.valid;
                pre_empty = tr.pre_empty;
                pre_full = tr.pre_full;

                case ({write_en, read_en})
                    2'b00 :  op = 0;
                    2'b01 :  op = 1;
                    2'b10 :  op = 2;
                    2'b11 :  op = 3;
                endcase
                if (pre_empty)
                    state = 0;
                else if (pre_full)
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
            
            return 100.0 * operations / 12.0; 
        endfunction

        task report();
            for (int i = 0; i < 3; i++) begin
                if (i == 0) begin
                    $display("Empty:");
                end
                if (i == 1) begin
                    $display("Normal:");
                end
                if (i == 2) begin
                    $display("Full:");
                end
                for (int j = 0; j < 4; j++) begin
                    if (j == 0) begin
                        $display("    Idle = %0d", op_state_count[j][i]);
                    end
                    if (j == 1) begin
                        $display("    Read = %0d", op_state_count[j][i]);
                    end
                    if (j == 2) begin
                        $display("    Write = %0d", op_state_count[j][i]);
                    end
                    if (j == 3) begin
                        $display("    RW = %0d", op_state_count[j][i]);
                    end
                end
            end
        endtask 

    endclass 
endpackage