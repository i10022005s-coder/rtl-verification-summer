package mips_environment_pkg;
    import mips_transaction_pkg::*;

    import mips_monitor_pkg::*;
    import mips_scoreboard_pkg::*;

    class mips_environment;
        virtual mips_if vif;
        int unsigned transaction_count;
        int unsigned errors = 0;

        mips_monitor monitor;
        mips_scoreboard scoreboard;
        
        mailbox #(mips_transaction) mon2scb;
        mailbox #(mips_transaction) mon2cov;

        function new(
            virtual mips_if vif,
            int unsigned transaction_count
        );
            this.vif = vif;
            this.transaction_count = transaction_count;
        endfunction

        function void build();
            mon2scb = new();
            mon2cov = new();

            monitor = new(vif, mon2scb, mon2cov, transaction_count);
            scoreboard = new(mon2scb, transaction_count);
        endfunction

        task run();
            fork
                print_progress();
                monitor.run();
                scoreboard.run();
                
            join
            errors = scoreboard.errors;
            environment_check();

            summary();
        endtask 

        task print_progress();
        while(scoreboard.checked_count < transaction_count) begin
            @(scoreboard.checked_count);
            if (scoreboard.checked_count == 0) begin
                $display("\tALU TEST START\n");
            end
            if (scoreboard.checked_count == 7) begin
                $display("\tALU TEST DONE\n");
                $display("\tZERO REGISTER TEST START\n");
            end
            if (scoreboard.checked_count == 8) begin
                $display("\tZERO REGISTER TEST DONE\n");
                $display("\tNEGATIVE NUMBERS TEST START\n");
            end
            if (scoreboard.checked_count == 12) begin
                $display("\tNEGATIVE NUMBERS TEST DONE\n");
                $display("\tMEMORY TEST START\n");
            end
            if (scoreboard.checked_count == 14) begin
                $display("\tMEMORY TEST DONE\n");
                $display("\tBEQ TEST START\n");
            end
            if (scoreboard.checked_count == 19) begin
                $display("\tBEQ TEST DONE\n");
            end
        end
            
        endtask 

        task environment_check();
            if ( (monitor.observed_count !== transaction_count) || 
            (scoreboard.checked_count !== transaction_count)) begin
                $error("Error of environment: monitor.observed_count = %0d, checked_count = %0d, expected=%0d.", 
                monitor.observed_count, scoreboard.checked_count, transaction_count);
                errors++;
            end
        endtask

        function void summary();
            $display("==================================================\nMIPS VERIFICATION SUMMARY\n==================================================\n\tTransactions observed: %d\n\tTransactions checked:  %d\n\tScoreboard errors:      %d", 
            monitor.observed_count, scoreboard.checked_count, scoreboard.errors);
            if (scoreboard.errors == 0) begin
                $display("ALL MIPS TESTS PASSED");
            end
            else $display("SOME MIPS TESTS FAILED");
            
        endfunction

    endclass 
endpackage