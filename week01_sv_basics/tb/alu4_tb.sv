`timescale 1ns/1ps

module test;

    logic [3:0] a, b, op, result;
    logic carry, overflow, zero;

    int errors;

    alu4 dut_alu4 (
        .a (a),
        .b (b),
        .op (op),
        .result (result),
        .carry (carry),
        .overflow (overflow),
        .zero (zero)
    );

    function automatic logic [6:0] expected_result(input logic [3:0] ain, input logic [3:0] bin, input logic [3:0] opin);
        begin
            expected_result = '0;
            case (opin)
                4'b0000: begin
                    expected_result[4:0] = ain + bin;
                    expected_result[5] = (~(ain[3] ^ bin[3])) & (expected_result[3] ^ ain[3]);
                end
                4'b0001: begin
                    expected_result[3:0] = ain - bin;
                    expected_result[4] = ain < bin;
                    expected_result[5] = (ain[3] ^ bin[3]) & (expected_result[3] ^ ain[3]);
                end
                4'b0010: expected_result[3:0] = ain & bin;
                4'b0011: expected_result[3:0] = ain | bin;
                4'b0100: expected_result[3:0] = ain ^ bin;
                4'b0101: expected_result[3:0] = ($signed(ain) < $signed(bin)) ? 4'b0001 : 4'b0000;
                4'b0110: expected_result[3:0] = (ain < bin) ? 4'b0001 : 4'b0000;
                4'b0111: expected_result[3:0] = ain << 1;
                4'b1000: expected_result[3:0] = ain >> 1;
                4'b1001: expected_result[3:0] = $signed(ain) >>> 1;
                default: expected_result = '0;
            endcase
            expected_result[6] = (expected_result[3:0] == 4'b0000);
        end
    endfunction

    task automatic check_alu4(input logic [3:0] ain, input logic [3:0] bin, input logic [3:0] opin);
        logic [6:0] expected;
        logic [6:0] actual;
        begin
            a = ain;
            b = bin;
            op = opin;
            #1;
            expected = expected_result(ain, bin, opin);
            actual = {zero, overflow, carry, result};
            if (actual !== expected) begin
                $error("Fail: a = %b b = %b op = %b expected = %b, (zero, overflow, carry, result) = %b", ain, bin, opin, expected, actual);
                errors = errors + 1;
            end
        end    
    endtask

    initial begin
        $dumpfile("alu4_tb.vcd");
        $dumpvars(0, test);
        errors=0;

        $display("Alu4 test");
        for (int i = 0; i < 16; i++) begin
            for (int j = 0; j < 16; j++) begin
                for (int k = 0; k < 16; k++) begin
                    check_alu4(i, j, k);
                end
            end
        end
        if (errors == 0) begin
            $display("Test passed");
        end
        else begin
            $display("TEST FAILED: errors=%0d", errors);
        end
        
        $finish;
    end

endmodule