package mips_monitor_pkg;
    import mips_transaction_pkg::*;

    class mips_monitor;
        virtual mips_if vif;
        int unsigned transaction_count; 
        int unsigned observed_count;
        logic reset;

        mailbox #(mips_transaction) outbox1;
        mailbox #(mips_transaction) outbox2;
        
        function new(
            virtual mips_if vif,
            mailbox #(mips_transaction) outbox1,
            mailbox #(mips_transaction) outbox2,
            int unsigned transaction_count
        );
            this.vif = vif;
            this.outbox1 = outbox1;
            this.outbox2 = outbox2;
            this.transaction_count = transaction_count;
        endfunction

        task run();
            mips_transaction tr;
            int unsigned i = 0;
            repeat (transaction_count) begin
                tr = new();

                wait (!vif.reset);

                @(negedge vif.clock);
                #1;
                tr.pc_before = vif.pc;
                tr.instr = vif.instr;
                tr.we_reg = vif.we_reg;
                tr.wa_reg = vif.wa_reg;
                tr.wd_reg = vif.wd_reg;
                tr.we_mem = vif.we_mem;
                tr.wd_mem = vif.wd_mem;
                tr.address_mem = vif.address_mem;
                tr.rd_mem = vif.rd_mem;
                tr.id = i;
                tr.decode();

                @(posedge vif.clock); #1;
                tr.pc_after = vif.pc;
                //tr.rd_reg = vif.rd_reg;
                

                tr.print();

                outbox1.put(tr);
                outbox2.put(tr);
                i++;
            end
            observed_count = i;
        endtask 

    endclass 
endpackage