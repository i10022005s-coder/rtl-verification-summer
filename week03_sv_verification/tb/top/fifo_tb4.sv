`timescale 1ns/1ps

import fifo_transaction_pkg::*;
import fifo_environment_pkg::*;

module fifo_tb4;

    localparam int DATA_WIDTH = 8;
    localparam int DEPTH = 8;

    logic clock;

    int errors;
    int unsigned transaction_count = DEPTH * 9 + 26;

    fifo_environment #(
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH(DEPTH)
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

        $dumpfile("sim/fifo_tb4.vcd");
        $dumpvars(0, fifo_tb4);

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

        if (errors == 0) begin
            $display("ALL FIFO TESTS Passed");
        end
        else begin
            $fatal(1,"FIFO TESTS FAILED: errors=%0d", errors);
        end
        $finish;
        end

    initial begin
        #2000;
        $fatal(1, "Timeout");
    end

endmodule