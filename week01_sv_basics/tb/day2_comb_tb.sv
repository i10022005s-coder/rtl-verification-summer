`timescale 1ns/1ps

module comb_test;

    logic [3:0] a;
    logic [1:0] sel;
    logic y_assign;
    logic y_if;
    logic y_case;

    logic [3:0] a1;
    logic [3:0] b;
    logic eqin;
    logic gtin;
    logic ltin;
    logic eqout;
    logic gtout;
    logic ltout;

    int errors;
    int btest = 6;

    mux4_assign dut_assign (
        .a (a),
        .sel (sel),
        .y (y_assign)
    );
    mux4_if dut_if (
        .a (a),
        .sel (sel),
        .y (y_if)
    );
    mux4_case dut_case (
        .a (a),
        .sel (sel),
        .y (y_case)
    );
    comparator4 dut_comp (
        .a (a1),
        .b (b),
        .eqin (eqin),
        .gtin (gtin),
        .ltin (ltin),
        .eqout (eqout),
        .gtout (gtout),
        .ltout (ltout)
    );

    function automatic logic expected_result_mux4(input logic [3:0] ain, input logic [1:0] selin);
        begin
            expected_result_mux4 = 1'b0;
            if (selin == 2'b11) begin
                expected_result_mux4 = ain[3];
            end
            else if (selin == 2'b10) begin
                expected_result_mux4 = ain[2];
            end
            else if (selin == 2'b01) begin
                expected_result_mux4 = ain[1];
            end
            else if (selin == 2'b00) begin
                expected_result_mux4 = ain[0];
            end
        end
    endfunction
    function automatic logic [2:0] expected_result_comparator4 (input logic [3:0] ain, input logic [3:0] bin, input logic eqin, input logic gtin, input logic ltin);
        begin
            expected_result_comparator4 = 3'b000;
            if (ain == bin) begin
                if (eqin) begin
                    expected_result_comparator4 = 3'b100;    
                end
                if (gtin) begin
                    expected_result_comparator4 = 3'b010;    
                end
                if (ltin) begin
                    expected_result_comparator4 = 3'b001;    
                end
            end
            if (ain > bin) begin
                expected_result_comparator4 = 3'b010;
            end
            if (ain < bin) begin
                expected_result_comparator4 = 3'b001;
            end
        end
        
    endfunction

    task automatic check_different_mux4(input logic [3:0] ain, input logic [1:0] selin);
        logic expected;
        begin
            a = ain;
            sel = selin;
            #1;
            expected = expected_result_mux4(ain, selin);
            if (y_assign != expected) begin
                $error("Fail: a = %b sel = %b expected = %b, y_assign = %b", ain, selin, expected, y_assign);
                errors = errors + 1;
            end
            else begin
                $display("Pass: a = %b sel = %b y_assign = %b", ain, selin, y_assign);
            end
            if (y_if != expected) begin
                $error("Fail: a = %b sel = %b expected = %b, y_if = %b", ain, selin, expected, y_if);
                errors = errors + 1;
            end
            else begin
                $display("Pass: a = %b sel = %b y_if = %b", ain, selin, y_if);
            end
            if (y_case != expected) begin
                $error("Fail: a = %b sel = %b expected = %b, y_case = %b", ain, selin, expected, y_case);
                errors = errors + 1;
            end
            else begin
                $display("Pass: a = %b sel = %b y_case = %b", ain, selin, y_case);
            end
        end    
    endtask
    task automatic check_comparator4(input logic [3:0] ain, input logic [3:0] bin, input logic eqin1, input logic gtin1, input logic ltin1);
        logic [2:0] expected;
        logic [2:0] actual;
        begin
            a1 = ain;
            b = bin;
            eqin = eqin1;
            gtin = gtin1;
            ltin = ltin1;
            #1;
            expected = expected_result_comparator4(ain, bin, eqin1, gtin1, ltin1);
            actual = {eqout, gtout, ltout};
            if (actual != expected) begin
                $error("Fail: a = %b sel = %b expected = %b, (eq, gt, lt) = %b", ain, bin, expected, actual);
                errors = errors + 1;
            end
            else begin
                $display("Pass: a = %b sel = %b (eq, gt, lt) = %b", ain, bin, actual);
            end
        end    
    endtask 

    initial begin
        $dumpfile("day2_comb_tb.vcd");
        $dumpvars(0, comb_test);
        errors=0;

        $display("Mux4 test");//Проверка Мультплексоров4
        for (int i = 0; i < 16; i++) begin
            for (int j = 0; j < 4; j++) begin
                check_different_mux4(i, j);
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
            if (i == btest) begin
                check_comparator4(i, btest, 0, 0, 0);
                check_comparator4(i, btest, 1, 0, 0);
                check_comparator4(i, btest, 0, 1, 0);
                check_comparator4(i, btest, 0, 0, 1);
            end
            else begin
                check_comparator4(i, btest, 0, 0, 0);
            end
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
