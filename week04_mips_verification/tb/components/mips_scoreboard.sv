package mips_scoreboard_pkg;

    import mips_transaction_pkg::*;
    import mips_reference_model_pkg::*;

    class mips_scoreboard;
        mailbox #(mips_transaction) inbox;

        mips_transaction tr;

        mips_reference_model ref_model;

        int unsigned errors;
        int unsigned errors_in_tr;
        int unsigned transaction_count;
        int unsigned checked_count;

        function new(
            mailbox #(mips_transaction) inbox,
            int unsigned transaction_count
        );
            this.inbox = inbox;
            this.transaction_count = transaction_count;
            errors = 0;
            checked_count = 0;
            ref_model = new();
        endfunction

        function void check_pc();
            if (tr.pc_before !== ref_model.expected_pc) begin
                $error("==================================================\n[SCB] ERROR:\n\tTransaction %0d, PC = %h, %s\n\tpc_before mismatch\n\tExpected: %h\n\tActual: %h\n==================================================", 
                    checked_count, ref_model.expected_pc, ref_model.operation.name(), ref_model.expected_pc, tr.pc_before);
                    errors_in_tr++;
            end
            if (tr.pc_after !== ref_model.expected_next_pc) begin
                $error("==================================================\n[SCB] ERROR:\n\tTransaction %0d, PC = %h, %s\n\tpc_after mismatch\n\tExpected: %h\n\tActual: %h\n==================================================", 
                    checked_count, ref_model.expected_pc, ref_model.operation.name(), ref_model.expected_next_pc, tr.pc_after);
                    errors_in_tr++;
            end
            
        endfunction

        function void check_reg_effect();
            if (tr.we_reg !== ref_model.expected_reg_write) begin
                $error("==================================================\n[SCB] ERROR:\n\tTransaction %0d, PC = %h, %s\n\twe_reg mismatch\n\tExpected: %h\n\tActual: %h\n==================================================", 
                    checked_count, ref_model.expected_pc, ref_model.operation.name(), ref_model.expected_reg_write, tr.we_reg);
                    errors_in_tr++;
            end
            if (ref_model.expected_reg_write) begin//Остальное проверяем только в том случае, когда ожидается запись
                if (tr.wa_reg !== ref_model.expected_reg_addr) begin
                    $error("==================================================\n[SCB] ERROR:\n\tTransaction %0d, PC = %h, %s\n\twa_reg mismatch\n\tExpected: %h\n\tActual: %h\n==================================================", 
                        checked_count, ref_model.expected_pc, ref_model.operation.name(), ref_model.expected_reg_addr, tr.wa_reg);
                        errors_in_tr++;
                end
                if (tr.wd_reg !== ref_model.expected_reg_data) begin
                    $error("==================================================\n[SCB] ERROR:\n\tTransaction %0d, PC = %h, %s\n\twd_reg mismatch\n\tExpected: %h\n\tActual: %h\n==================================================", 
                        checked_count, ref_model.expected_pc, ref_model.operation.name(), ref_model.expected_reg_data, tr.wd_reg);
                        errors_in_tr++;
                end
            end
            
        endfunction

        function void check_mem_effect();
            if (tr.we_mem !== ref_model.expected_mem_write) begin
                $error("==================================================\n[SCB] ERROR:\n\tTransaction %0d, PC = %h, %s\n\twe_mem mismatch\n\tExpected: %h\n\tActual: %h\n==================================================", 
                    checked_count, ref_model.expected_pc, ref_model.operation.name(), ref_model.expected_mem_write, tr.we_mem);
                    errors_in_tr++;
            end
            if (ref_model.expected_mem_write) begin//Остальное проверяем только в том случае, когда ожидается запись
                if (tr.address_mem !== ref_model.expected_mem_addr) begin
                    $error("==================================================\n[SCB] ERROR:\n\tTransaction %0d, PC = %h, %s\n\taddress_mem mismatch\n\tExpected: %h\n\tActual: %h\n==================================================", 
                        checked_count, ref_model.expected_pc, ref_model.operation.name(), ref_model.expected_mem_addr, tr.address_mem);
                        errors_in_tr++;
                end
                if (tr.wd_mem !== ref_model.expected_mem_data) begin
                    $error("==================================================\n[SCB] ERROR:\n\tTransaction %0d, PC = %h, %s\n\twd_mem mismatch\n\tExpected: %h\n\tActual: %h\n==================================================", 
                        checked_count, ref_model.expected_pc, ref_model.operation.name(), ref_model.expected_mem_data, tr.wd_mem);
                        errors_in_tr++;
                end
            end
            
            
        endfunction
        
        task run();
            
            repeat (transaction_count) begin
                errors_in_tr = 0;

                inbox.get(tr);

                ref_model.predict(tr);

                if (!ref_model.prediction_valid) begin
                    $display("\n[SCB] WARNING: UNKNOWN OPERATION!\n");
                end
                check_pc();
                check_reg_effect();
                check_mem_effect();
                
                if (errors_in_tr !== 0) begin
                    errors++;
                    $display("\n[SCB] Incorrect operation: %s\n", ref_model.operation.name());
                end
                checked_count++;
            end
            
            $display("\n[SCB] Test is finished.\n");
        endtask 
    endclass

endpackage