package fifo_coverage_pkg;
    import fifo_transaction_pkg::*;

    class fifo_coverage;
        mailbox #(fifo_transaction) inbox;
        int unsigned transaction_count;
        int unsigned sampled_count;

        bit write_en, read_en;
        logic full, empty, valid;

        covergroup fifo_cg;
            cp_operation : coverpoint {write_en, read_en} {
                bins idle = {2'b00};
                bins write = {2'b10};
                bins read = {2'b01};
                bins rw = {2'b11};
            }
            cp_states : coverpoint {full, empty} {
                bins normal = {2'b00};
                bins empty = {2'b01};
                bins full = {2'b10};
                illegal_bins invalid = {2'b11};
            }
            cp_valid : coverpoint valid {
                bins invalid = {1'b0};
                bins valid = {1'b1};
            }

            operation_x_state :
                cross cp_operation, cp_states;
        endgroup

        function new(
            mailbox #(fifo_transaction) inbox,
            int unsigned transaction_count
        );
            this.inbox = inbox;
            this.transaction_count = transaction_count;
            sampled_count = 0;
            fifo_cg = new();
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

                fifo_cg.sample();

                sampled_count++;
            end
        endtask 

        function real get_coverage();
            return fifo_cg.get_inst_coverage();
            
        endfunction

    endclass 
endpackage