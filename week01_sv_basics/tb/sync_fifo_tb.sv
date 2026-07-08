`timescale 1ns/1ps

module test;

    logic clock, reset, write_en, read_en, valid, empty, full;
    logic [7:0] wdata, rdata;

    int errors;

    sync_fifo dut_sync_fifo(
        .clock(clock),
        .reset(reset),
        .write_en(write_en),
        .read_en(read_en),
        .wdata(wdata),
        .rdata(rdata),
        .valid(valid),
        .empty(empty),
        .full(full)
    );

    initial begin
        clock = 1'b0;
        forever begin
            #5 clock = ~clock;
        end
    end

    initial begin
        $dumpfile("sync_fifo_tb.vcd");
        $dumpvars(0, test);
        errors = 0;

        reset = 1'b1;
        repeat (2) @(posedge clock);
        reset = 1'b0;
        @(posedge clock);

        $display("Test 1. Push and pop.");
        @(negedge clock);
        read_en = 1'b0;
        write_en = 1'b1;
        wdata = 8'hA8;
        @(negedge clock);
        write_en = 1'b0;
        read_en = 1'b1;
        @(negedge clock);
        if ((rdata !== 8'hA8) | (valid !== 1'b1)) begin
            $error("FAIL: valid = %h rdata = %h expected = %h", valid, rdata, 8'hA8);
            errors++;
        end
        else $display("Check: valid = %h rdata = %h expected = %h", valid, rdata, 8'hA8);
        if (errors === 0) begin
            $display("Test passed.");
        end
        read_en = 1'b0;

        errors = 0;
        reset = 1'b1;
        repeat (2) @(posedge clock);
        reset = 1'b0;
        @(posedge clock);

        $display("Test 2. Push and pop.");
        //write_en = 1'b1;
        for (int i = 0; i < 9; i++) begin
            @(negedge clock);
            write_en = 1'b1;
            wdata = i;
        end
        @(negedge clock);
        write_en = 1'b0;
        //read_en = 1'b1;
        for (int i = 0; i < 8; i++) begin
            @(negedge clock);
            read_en = 1'b1;
            @(posedge clock);
            #1;
            if ((rdata !== i) | (valid !== 1'b1)) begin
                $error("FAIL: valid = %h rdata = %h expected = %h", valid, rdata, i);
                errors++;
            end
            else $display("Check: valid = %h rdata = %h expected = %h", valid, rdata, i);
        end
        @(negedge clock);
        read_en = 1'b0;
        if (errors === 0) begin
            $display("Test passed.");
        end
        $finish;
    end

endmodule