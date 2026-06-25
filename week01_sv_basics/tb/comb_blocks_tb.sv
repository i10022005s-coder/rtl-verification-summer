`timescale 1ns/1ps

module comb_test;

    logic [3:0] d;
    logic [1:0] y;
    logic valid;

    int errors;

    logic [1:0] a;
    logic [3:0] y1;

    logic [3:0] d2;
    logic [1:0] sel;
    logic y2;

    priority_encoder4 dut_en (
        .d (d),
        .y (y),
        .valid (valid)    
    );
    decoder2to4 dut_de (
        .a (a),
        .y1 (y1)    
    );
    mux4 dut_mux (
        .d2 (d2),
        .sel (sel),
        .y2 (y2)
    );

    function automatic logic [2:0] expected_result_priority_encoder4(input logic [3:0] din);
        begin
            if (din[3]) begin
                expected_result_priority_encoder4 = {2'b11, 1'b1};
            end
            else if (din[2]) begin
                expected_result_priority_encoder4 = {2'b10, 1'b1};
            end
            else if (din[1]) begin
                expected_result_priority_encoder4 = {2'b01, 1'b1};
            end
            else if (din[0]) begin
                expected_result_priority_encoder4 = {2'b00, 1'b1};
            end
            else begin
                expected_result_priority_encoder4 = {2'b00, 1'b0};
            end
        end
    endfunction
    function automatic logic [3:0] expected_result_decoder2to4(input logic [1:0] ain);
        begin
            if (ain == 2'b11) begin
                expected_result_decoder2to4 = 4'b1000;
            end
            else if (ain == 2'b10) begin
                expected_result_decoder2to4 = 4'b0100;
            end
            else if (ain == 2'b01) begin
                expected_result_decoder2to4 = 4'b0010;
            end
            else if (ain == 2'b00) begin
                expected_result_decoder2to4 = 4'b0001;
            end
        end
    endfunction
    function automatic logic expected_result_mux4(input logic [3:0] din, input logic [1:0] selin);
        begin
            if (selin == 2'b11) begin
                expected_result_mux4 = din[3];
            end
            else if (selin == 2'b10) begin
                expected_result_mux4 = din[2];
            end
            else if (selin == 2'b01) begin
                expected_result_mux4 = din[1];
            end
            else if (selin == 2'b00) begin
                expected_result_mux4 = din[0];
            end
        end
    endfunction

    task automatic check_priority_encoder4(input logic [3:0] din);
        logic [2:0] expected;
        logic [2:0] actual;

        begin
            d=din;
            #1;

            expected = expected_result_priority_encoder4(din);
            actual = {y, valid};

            if (actual !== expected) begin
                $error("FAIL: d=%b expected valid=%b y=%b, got valid=%b, y=%b", din, expected[2], expected[1:0], valid, y);
                errors = errors + 1;
            end
            else begin
                $display("PASS: d=%b valid=%b y=%b", din, valid, y);
            end
        end
    endtask 
    task automatic check_decoder2to4(input logic [2:0] ain);
        logic [3:0] expected;
        logic [3:0] actual;

        begin
            a=ain;
            #1;

            expected = expected_result_decoder2to4(ain);
            actual = y1;

            if (actual !== expected) begin
                $error("FAIL: a=%b expected y=%b, got y=%b", ain, expected, actual);
                errors = errors + 1;
            end
            else begin
                $display("PASS: a=%b y=%b", ain, y1);
            end
        end
    endtask 
    task automatic check_mux4(input logic [3:0] din, input logic [1:0] selin);
        logic expected;
        logic actual;

        begin
            d2=din;
            sel=selin;
            #1;

            expected = expected_result_mux4(din, selin);
            actual = y2;

            if (actual !== expected) begin
                $error("FAIL: d=%b, sel=%b expected y=%b, got y=%b", din, selin, expected, actual);
                errors = errors + 1;
            end
            else begin
                $display("PASS: d=%b, sel=%b expected y=%b, got y=%b", din, selin, expected, actual);
            end
        end
    endtask 

    initial begin
        $dumpfile("comb_blocks_tb.vcd");
        $dumpvars(0, comb_test);
        errors=0;
        
        $display("Priority_encoder4 test");//Проверка приоритетного шифратора
        for (int i = 0; i < 16; i++) begin
            check_priority_encoder4(i);
        end
        
        if (errors == 0) begin
            $display("Test passed");
        end
        else begin
            $display("TEST FAILED: errors=%0d", errors);
        end
        errors=0;

        $display("Decoder2to4 test");//Проверка дешифратора 2 в 4
        for (int i = 0; i < 4; i++) begin
            check_decoder2to4(i);
        end
        
        if (errors == 0) begin
            $display("Test passed");
        end
        else begin
            $display("TEST FAILED: errors=%0d", errors);
        end
        errors=0;

        $display("Mux4 test");//Проверка Мультплексора4
        for (int i=0; i<16; i++) begin
            for (int j = 0; j<4; j++) begin
                check_mux4(i, j);
            end
        end
        if (errors == 0) begin
            $display("Test passed");
        end
        else begin
            $display("TEST FAILED: errors=%0d", errors);
        end
        errors=0;

        $finish;
    end
endmodule 