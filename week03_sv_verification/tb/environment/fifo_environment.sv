package fifo_environment_pkg;
    import fifo_transaction_pkg::*;

    import fifo_driver_pkg::*;
    import fifo_generator_pkg::*;
    import fifo_monitor_pkg::*;
    import fifo_scoreboard_pkg::*;
    import fifo_coverage_pkg::*;

    class fifo_environment #(
        parameter  int DATA_WIDTH = 8,
        parameter  int DEPTH = 8
    );
        virtual fifo_if vif;
        int unsigned transaction_count;
        int unsigned errors = 0;

        fifo_generator #(
            .DATA_WIDTH(DATA_WIDTH),
            .DEPTH(DEPTH)
        ) generator;
        fifo_driver driver;
        fifo_monitor monitor;
        fifo_scoreboard #(
            .DATA_WIDTH(DATA_WIDTH),
            .DEPTH(DEPTH)
        ) scoreboard;
        fifo_coverage coverage;
        int unsigned seed = 12345;

        mailbox #(fifo_transaction) gen2drv;
        mailbox #(fifo_transaction) mon2scb;
        mailbox #(fifo_transaction) mon2cov;

        function new(
            virtual fifo_if vif,
            int unsigned transaction_count
        );
            this.vif = vif;
            this.transaction_count = transaction_count;
        endfunction

        function void build();
            gen2drv = new();
            mon2scb = new();
            mon2cov = new();

            generator = new(gen2drv, transaction_count);
            driver = new(vif, gen2drv, transaction_count);
            monitor = new(vif, mon2scb, mon2cov, transaction_count);
            scoreboard = new(mon2scb, transaction_count);
            coverage = new(mon2cov, transaction_count);
        endfunction

        task run();
            fork
                generator.run();
                driver.run();
                monitor.run();
                scoreboard.run();
                coverage.run();
            join
        endtask 

        task environment_check();
            if ( (generator.generated_count !== transaction_count) || 
            (driver.driven_count !== transaction_count) || 
            (monitor.observed_count !== transaction_count) || 
            (scoreboard.checks !== transaction_count) || 
            (coverage.sampled_count !== transaction_count)) begin
                $error("Error of environment: generator.generated_count = %0d, driver.driven_count = %0d, monitor.observed_count = %0d, scoreboard.checks = %0d, coverage.sampled_count = %0d, expected=%0d.", 
                generator.generated_count, driver.driven_count, monitor.observed_count, scoreboard.checks, coverage.sampled_count, transaction_count);
                errors++;
            end
        endtask 

    endclass 
endpackage