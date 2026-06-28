`timescale 1ns/1ps

module test;

    logic a1, b1, summ_half, summ_full, carry, cin, cout_full, cout_adder4, borrow, eq, gt, lt;
    logic [3:0] a, b, summ, diff;

    int errors;
    int btest = 6;

    half_adder dut_half (
        .a (a1),
        .b (b1),
        .summ (summ_half),
        .carry (carry)
    );
    full_adder dut_full (
        .a (a1),
        .b (b1),
        .cin (cin),
        .summ (summ_full),
        .cout (cout_full)
    );
    adder4 dut_adder4 (
        .a (a),
        .b (b),
        .cin (cin),
        .summ (summ),
        .cout (cout_adder4)
    );
    substractor4 dut_substractor4 (
        .a (a),
        .b (b),
        .diff (diff),
        .borrow (borrow)
    );
    comparator4 dut_comp (
        .a (a),
        .b (b),
        .eq (eq),
        .gt (gt),
        .lt (lt)
    );

    function automatic logic [1:0] expected_result_half_adder(input logic ain, input logic bin);
        begin
            expected_result_half_adder = 2'b00;
            if (ain ^ bin) begin
                expected_result_half_adder = 2'b01;
            end
            else begin
                if (ain & bin) begin
                    expected_result_half_adder = 2'b10;
                end
            end
        end    
    endfunction
    function automatic logic [1:0] expected_result_full_adder(input logic ain, input logic bin, input logic cin);
        logic summ_exp;
        logic cout_exp;
        begin
            expected_result_full_adder = 2'b00;
            summ_exp = ain ^ bin ^ cin;
            cout_exp = (ain & bin) | (cin & bin) | (ain & cin);
            expected_result_full_adder = {cout_exp, summ_exp};
        end    
    endfunction
    function automatic logic [4:0] expected_result_adder4(input logic [3:0] ain, input logic [3:0] bin, input logic cin);
        begin
            expected_result_adder4 = ain + bin + cin;
        end    
    endfunction
    function automatic logic [4:0] expected_result_subtractor4(input logic [3:0] ain, input logic [3:0] bin);
        begin
            expected_result_subtractor4 = {
                (ain < bin),
                (ain - bin)
            };
        end
    endfunction
    function automatic logic [2:0] expected_result_comparator4 (input logic [3:0] ain, input logic [3:0] bin);
        begin
            expected_result_comparator4 = 3'b000;
            if (ain == bin) begin
                expected_result_comparator4 = 3'b100;
            end
            else if (ain > bin) begin
                expected_result_comparator4 = 3'b010;
            end
            else if (ain < bin) begin
                expected_result_comparator4 = 3'b001;
            end
        end  
    endfunction

    task automatic check_comparator4(input logic [3:0] ain, input logic [3:0] bin);
        logic [2:0] expected;
        logic [2:0] actual;
        begin
            a = ain;
            b = bin;
            #1;
            expected = expected_result_comparator4(ain, bin);
            actual = {eq, gt, lt};
            if (actual != expected) begin
                $error("Fail: a = %b b = %b expected = %b, (eq, gt, lt) = %b", ain, bin, expected, actual);
                errors = errors + 1;
            end
        end    
    endtask 
    task automatic check_half_adder(input logic ain, input logic bin);
        logic [1:0] expected;
        logic [1:0] actual;
        begin
            a1 = ain;
            b1 = bin;
            #1;
            expected = expected_result_half_adder(ain, bin);
            actual = {carry, summ_half};
            if (actual != expected) begin
                $error("Fail: a = %b b = %b expected = %b, {carry, summ1} = %b", ain, bin, expected, actual);
                errors = errors + 1;
            end
        end    
    endtask 
    task automatic check_full_adder(input logic ain, input logic bin, input logic cin1);
        logic [1:0] expected;
        logic [1:0] actual;
        begin
            a1 = ain;
            b1 = bin;
            cin = cin1;
            #1;
            expected = expected_result_full_adder(ain, bin, cin1);
            actual = {cout_full, summ_full};
            if (actual != expected) begin
                $error("Fail: a = %b b = %b cin = %b expected = %b, {cout, summ1} = %b", ain, bin, cin1, expected, actual);
                errors = errors + 1;
            end
        end    
    endtask 
    task automatic check_adder4(input logic [3:0] ain, input logic [3:0] bin, input logic cin1);
        logic [4:0] expected;
        logic [4:0] actual;
        begin
            a = ain;
            b = bin;
            cin = cin1;
            #1;
            expected = expected_result_adder4(ain, bin, cin1);
            actual = {cout_adder4, summ};
            if (actual != expected) begin
                $error("Fail: a = %b b = %b cin = %b expected = %b, {cout, summ} = %b", ain, bin, cin1, expected, actual);
                errors = errors + 1;
            end
        end    
    endtask 
    task automatic check_sudstractor4(input logic [3:0] ain, input logic [3:0] bin);
        logic [4:0] expected;
        logic [4:0] actual;
        begin
            a = ain;
            b = bin;
            #1;
            expected = expected_result_subtractor4(ain, bin);
            actual = {borrow, diff};
            if (actual != expected) begin
                $error("Fail: a = %b b = %b expected = %b, {borrow, diff} = %b", ain, bin, expected, actual);
                errors = errors + 1;
            end
        end    
    endtask 

    initial begin
        $dumpfile("arith_tb.vcd");
        $dumpvars(0, test);
        errors=0;

        $display("Half adder test");//Проверка Полусумматора
        for (int i = 0; i < 2; i++) begin
            for (int j = 0; j < 2; j++) begin
                check_half_adder(i,j);
            end
        end
        if (errors == 0) begin
            $display("Test passed");
        end
        else begin
            $display("TEST FAILED: errors=%0d", errors);
        end
        errors=0;

        $display("Full adder test");//Проверка Полного сумматора
        for (int i = 0; i < 2; i++) begin
            for (int j = 0; j < 2; j++) begin
                for (int k = 0; k < 2; k++) begin
                    check_full_adder(i, j, k);
                end
            end
        end
        if (errors == 0) begin
            $display("Test passed");
        end
        else begin
            $display("TEST FAILED: errors=%0d", errors);
        end
        errors=0;

        $display("Adder4 test");//Проверка сумматора4
        for (int i = 0; i < 16; i++) begin
            for (int j = 0; j < 16; j++) begin
                for (int k = 0; k < 2; k++) begin
                    check_adder4(i, j, k);
                end
            end
        end
        if (errors == 0) begin
            $display("Test passed");
        end
        else begin
            $display("TEST FAILED: errors=%0d", errors);
        end
        errors=0;
        $display("Substractor4 test");//Проверка Вычитателя4
        for (int i = 0; i < 16; i++) begin
            for (int j = 0; j < 16; j++) begin
                check_sudstractor4(i, j);
            end
        end
        if (errors == 0) begin
            $display("Test passed");
        end
        else begin
            $display("TEST FAILED: errors=%0d", errors);
        end
        errors=0;

        $display("Comparator4 test");//Проверка Компаратора4
        for (int i = 0; i < 16; i++) begin
            check_comparator4(i, btest);
        end
        if (errors == 0) begin
            $display("Comparator4 test passed");
        end
        else begin
            $display("Comparator4 TEST FAILED: errors=%0d", errors);
        end
        $finish;
    end

endmodule