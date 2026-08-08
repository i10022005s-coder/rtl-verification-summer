package fifo_generator_pkg;
    import fifo_transaction_pkg::*;

    class fifo_generator;
        mailbox #(fifo_transaction) outbox;
        int unsigned transaction_count;
        int unsigned id;

        function new(
            mailbox #(fifo_transaction) outbox,
            int unsigned transaction_count
        );
            this.outbox = outbox;
            this.transaction_count = transaction_count;
        endfunction
        
        task run();
            fifo_transaction tr;
            int unsigned i;
            i = 0;
            repeat (transaction_count) begin
                tr = new();
                tr.generate_random();
                tr.id = i;

                tr.print("Generator:");
                outbox.put(tr);
                i++;
            end
            id = i;
        endtask 

    endclass 
endpackage