`timescale 1ns/1ps

module test;
    
    logic clock, reset, we;
    logic [4:0] ra1, ra2, wa;
    logic [31:0] rd1, rd2, wd;

    int errors;

    reg_file dut_reg_file (
        .clock (clock),
        .reset (reset),
        .we (we),
        .ra1 (ra1),
        .ra2 (ra2),
        .wa (wa),
        .rd1 (rd1),
        .rd2 (rd2),
        .wd (wd)
    );

    initial begin
        clock = 1'b0;
        forever begin
            #5 clock = ~clock;
        end
    end

    task automatic write_reg(input logic [4:0] addr, input logic [31:0] data);
        begin
            @(negedge clock);
            we = 1'b1;
            wa = addr;
            wd = data;
            @(negedge clock);
            we = 1'b0;
            wa = '0;
            wd = '0;
        end
    endtask 

    task automatic check_read(input logic [4:0] addr1,
    input logic [31:0] expected1,
    input logic [4:0] addr2,
    input logic [31:0] expected2
    );
    begin
        ra1 = addr1;
        ra2 = addr2;

        #1;
        if (rd1 !== expected1) begin
            $error("rd1 error: ra1=%0d expected=%h got=%h", addr1, expected1, rd1);
            errors++;
        end
        if (rd2 !== expected2) begin
            $error("rd2 error: ra2=%0d expected=%h got=%h", addr2, expected2, rd2);
            errors++;
        end
    end
    endtask

    initial begin
        $dumpfile("reg_file_tb.vcd");
        $dumpvars(0, test);
        errors = 0;

        reset = 1'b1;
        repeat (2) @(posedge clock);
        reset = 1'b0;
        @(posedge clock);

        $display("Test 1. Check reset.");
        errors = 0;
        for (int i = 0; i < 32; i++) begin
            check_read(i, '0, i, '0);
        end
        if (errors == 0) begin
            $display("Test 1 PASS.");
        end
        else begin
            $display("Test 1 FAIL.");
        end

        $display("Test 2. Check write we = 1.");
        errors = 0;
        @(negedge clock);
        we = 1'b1;
        wa = 'b101;
        wd = 'b1011;
        @(posedge clock);
        check_read('b101, 'b1011, 'b101, 'b1011);
        if (errors == 0) begin
            $display("Test 2 PASS.");
        end
        else begin
            $display("Test 2 FAIL.");
        end 

        $display("Test 3. Check write we = 0d.");
        errors = 0;
        @(negedge clock);
        we = 1'b0;
        wa = 'b100;
        wd = 'b1011;
        @(posedge clock);
        check_read('b100, '0, 'b100, '0);
        if (errors == 0) begin
            $display("Test 3 PASS.");
        end
        else begin
            $display("Test 3 FAIL.");
        end

        $display("Test 3. Check from two different register.");
        errors = 0;
        @(negedge clock);
        we = 1'b1;
        wa = 'b10;
        wd = 'b101;
        @(negedge clock);
        we = 1'b1;
        wa = 'b11;
        wd = 'b100;
        @(posedge clock);
        check_read('b10, 'b101, 'b11, 'b100);
        if (errors == 0) begin
            $display("Test 4 PASS.");
        end
        else begin
            $display("Test 4 FAIL.");
        end 

        $display("Test 5. Check r0.");
        errors = 0;
        @(negedge clock);
        we = 1'b1;
        wa = '0;
        wd = 'b1011;
        @(posedge clock);
        check_read('0, '0, '0, '0);
        if (errors == 0) begin
            $display("Test 5 PASS.");
        end
        else begin
            $display("Test 5 FAIL.");
        end

        $finish;
    end

endmodule