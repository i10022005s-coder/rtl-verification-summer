`timescale 1ns/1ps

import fifo_transaction_pkg::*;
import fifo_generator_pkg::*;
import fifo_driver_pkg::*;

module fifo_tb2;

    localparam int DATA_WIDTH = 8;
    localparam int DEPTH = 4;

    logic clock;

    int errors;
    int unsigned transaction_count = 16;
    int unsigned generator_count, driver_count;

    mailbox #(fifo_transaction) gen2drv;

    fifo_generator gen;
    fifo_driver    drv;

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
        gen2drv = new(8);
        gen = new(gen2drv, transaction_count);
        drv = new(fifo_bus, gen2drv, transaction_count);

        $dumpfile("sim/fifo_tb2.vcd");
        $dumpvars(0, fifo_tb2);

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
        
        $display("Test 2. Generator to driver.");
        fork
            gen.run();
            drv.run();
        join
        generator_count = gen.id;
        driver_count = drv.id;
        if (generator_count !== transaction_count) begin
            $error("Error of generator: get = %0d, expected=%0d.", generator_count, transaction_count);
            errors++;
        end
        if (driver_count !== transaction_count) begin
            $error("Error of driver: get = %0d, driver=%0d.", driver_count, transaction_count);
            errors++;
        end


        if (errors == 0) begin
            $display("ALL FIFO TESTS Passed");
        end
        else begin
            $fatal(1,"FIFO INTERFACE TESTS FAILED: errors=%0d", errors);
        end
        $finish;
        end

    initial begin
        #1000;
        $fatal(1, "Timeout");
    end

endmodule