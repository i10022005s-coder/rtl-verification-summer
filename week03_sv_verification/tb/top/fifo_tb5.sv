`timescale 1ns/1ps

import fifo_transaction_pkg::*;
import fifo_environment_pkg::*;

module fifo_tb5;

    localparam int DATA_WIDTH = 8;
    localparam int DEPTH = 8;

    localparam int DIRECTED_COUNT = 4 * DEPTH + 26;
    localparam int RANDOM_COUNT   = DEPTH * 3;
    localparam int STRESS_COUNT   = 10000;

    localparam int TRANSACTION_COUNT = DIRECTED_COUNT + 3 * RANDOM_COUNT + STRESS_COUNT;

    localparam time TIMEOUT = (TRANSACTION_COUNT + 100) * 20ns;

    logic clock;

    int errors;
    int unsigned transaction_count = TRANSACTION_COUNT;

    fifo_environment #(
        DATA_WIDTH,
        DEPTH
    ) env;

    fifo_if #(
        .DATA_WIDTH(DATA_WIDTH)
    ) fifo_bus(
        .clock(clock)
    );

    sync_fifo #(
        .WIDTH(DATA_WIDTH),
        .DEPTH(DEPTH)
    ) dut (
        .clock (fifo_bus.clock),
        .reset (fifo_bus.reset),
        .write_en (fifo_bus.write_en),
        .read_en (fifo_bus.read_en),
        .wdata (fifo_bus.write_data),

        .rdata (fifo_bus.read_data),
        .full (fifo_bus.full),
        .empty (fifo_bus.empty),
        .valid (fifo_bus.valid)
    );

    initial begin
        clock = 1'b0;
        forever #5 clock = ~clock;
    end

    initial begin
        errors = 0;

        $dumpfile("sim/fifo_tb5.vcd");
        $dumpvars(0, fifo_tb5);

        fifo_bus.reset = 1'b1;
        fifo_bus.write_en = 1'b0;
        fifo_bus.read_en = 1'b0;
        fifo_bus.write_data = '0;

        $display("Test 1. Reset.");
        repeat (2) @(posedge clock);
        #1;
        if (fifo_bus.empty !== 1'b1) begin
            $error("After reset: empty = %0b, expected=1.", fifo_bus.empty);
            errors++;
        end
        if (fifo_bus.full !== 1'b0) begin
            $error("After reset: full = %0b, expected=0.", fifo_bus.full);
            errors++;
        end
        if (fifo_bus.valid !== 1'b0) begin
            $error("After reset: valid = %0b, expected=0.", fifo_bus.valid);
            errors++;
        end
        @(negedge clock);
        fifo_bus.reset = 1'b0;
        @(posedge clock);
        #1;
        
        $display("Test 2. TB with environment (directed and random) and environment check.");
        env = new(fifo_bus, transaction_count);
        env.build();
        env.run();
        env.environment_check();
        if (env.scoreboard.errors !== 0)begin
            errors++;
        end
        if (env.errors !== 0)begin
            errors++;
        end

        $display("Functional coverage: %0.2f%%", env.coverage.get_coverage());
        $display("Write: %0d", env.generator.write_counter);
        $display("Read: %0d", env.generator.read_counter);
        $display("RW: %0d", env.generator.rw_counter);
        $display("Idle: %0d", env.generator.idle_counter);
        $display("Random transactions: %0d", env.generator.transaction_counter);
        $display("Total transactions: %0d", env.generator.generated_count);
        if (errors == 0) begin
            $display("ALL FIFO TESTS Passed");
        end
        else begin
            $fatal(1,"FIFO TESTS FAILED: errors=%0d", errors);
        end
        $finish;
        end

    initial begin
        #(TIMEOUT);
        $fatal(1, "Timeout");
    end

endmodule