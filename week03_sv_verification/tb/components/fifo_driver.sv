package fifo_driver_pkg;
    import fifo_transaction_pkg::*;

    class fifo_driver;
        virtual fifo_if vif;
        mailbox #(fifo_transaction) inbox;
        int unsigned transaction_count;
        int unsigned id;

        function new(
            virtual fifo_if vif,
            mailbox #(fifo_transaction) inbox,
            int unsigned transaction_count
        );
            this.vif = vif;
            this.inbox = inbox;
            this.transaction_count = transaction_count;
        endfunction
        
        task run();
            fifo_transaction tr;
            int i = 0;
            repeat (transaction_count) begin
                inbox.get(tr);
                one_drive(tr);
                i++;
            end
            id = i;
        endtask 

        task one_drive(input fifo_transaction tr);
            @(negedge vif.clock);
            vif.write_en = tr.write_en;
            vif.read_en = tr.read_en;
            vif.write_data = tr.write_data;
            tr.print("Driver:");

            @(posedge vif.clock); #1;
            vif.write_en = 1'b0;
            vif.read_en = 1'b0;
            vif.write_data = '0;
        endtask

    endclass 
endpackage