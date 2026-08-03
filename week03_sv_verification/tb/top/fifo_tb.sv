`timescale 1ns/1ps

import fifo_transaction_pkg::*;

module fifo_tb;

    localparam int DATA_WIDTH = 8;
    localparam int DEPTH = 4;

    logic clock;

    int errors;

    fifo_transaction tr;
    fifo_transaction random_tr;

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

        $dumpfile("sim/fifo_tb.vcd");
        $dumpvars(0, fifo_tb);

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

        @(negedge clock);
        fifo_bus.reset = 1'b0;

        $display("Test 2. Random transactions.");
        repeat (3) begin
            random_tr = new();
            random_tr.generate_random();
            random_tr.print("Random transaction");
        end

        $display("Test 3. Write through transaction.");
        tr = new();
        tr.write_en = 1'b1;
        tr.read_en = 1'b0;
        tr.write_data = 8'hA5;
        tr.print("Write transaction");
        @(negedge clock);
        fifo_bus.write_en = tr.write_en;
        fifo_bus.read_en = tr.read_en;
        fifo_bus.write_data = tr.write_data;
        @(posedge clock);
        @(negedge clock);
        fifo_bus.write_en = 1'b0;
        fifo_bus.read_en = 1'b0;
        fifo_bus.write_data = '0;
        if (fifo_bus.empty !== 1'b0) begin
            $error("After write: empty=%0b expected=0",fifo_bus.empty);
            errors++;
        end

        $display("Test 4. Read through transaction.");
        tr = new();
        tr.write_en = 1'b0;
        tr.read_en = 1'b1;
        tr.write_data = '0;
        tr.print("Read transaction");
         @(negedge clock);
        fifo_bus.write_en = tr.write_en;
        fifo_bus.read_en = tr.read_en;
        fifo_bus.write_data = tr.write_data;
        @(posedge clock);
        #1;
        if (fifo_bus.read_data !== 8'hA5) begin
            $error("Read data = 0x%02h expected = 0xA5", fifo_bus.read_data);
            errors++;
        end
        if (fifo_bus.valid !== 1'b1) begin
            $error("Valid = %0b expected = 1", fifo_bus.valid);
            errors++;
        end
        @(negedge clock);
        fifo_bus.write_en = 1'b0;
        fifo_bus.read_en = 1'b0;
        fifo_bus.write_data = '0;
        #1;
        if (fifo_bus.empty !== 1'b1) begin
            $error("After reset: empty = %0b, expected=1.", fifo_bus.empty);
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