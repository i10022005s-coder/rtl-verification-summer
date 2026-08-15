package fifo_monitor_pkg;
    import fifo_transaction_pkg::*;

    class fifo_monitor;
        virtual fifo_if vif;
        int unsigned transaction_count;
        int unsigned observed_count;

        mailbox #(fifo_transaction) outbox1;
        mailbox #(fifo_transaction) outbox2;
        
        function new(
            virtual fifo_if vif,
            mailbox #(fifo_transaction) outbox1,
            mailbox #(fifo_transaction) outbox2,
            int unsigned transaction_count
        );
            this.vif = vif;
            this.outbox1 = outbox1;
            this.outbox2 = outbox2;
            this.transaction_count = transaction_count;
        endfunction

        task run();
            fifo_transaction tr;
            int unsigned i = 0;
            repeat (transaction_count) begin
                tr = new();
                tr.id = i;

                @(negedge vif.clock); #1;
                tr.write_en = vif.write_en;
                tr.read_en = vif.read_en;
                tr.write_data = vif.write_data;

                @(posedge vif.clock); #1;
                tr.read_data = vif.read_data;
                tr.empty = vif.empty;
                tr.full = vif.full;
                tr.valid = vif.valid;

                outbox1.put(tr);
                outbox2.put(tr);
                i++;
            end
            observed_count = i;
        endtask 

    endclass 
endpackage