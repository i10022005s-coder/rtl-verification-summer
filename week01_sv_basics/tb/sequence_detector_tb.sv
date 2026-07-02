`timescale 1ns/1ps

module test;

    logic clock, reset, serial_in, detected;

    int errors;

    integer file;
    integer scan_result;
    logic bit_from_file;

    logic [3:0] history;
    logic expected_detected;

    sequence_detector_1011 dut_sequence_detector_1011 (
        .clock (clock),
        .reset (reset),
        .serial_in (serial_in),
        .detected (detected)
    );

    initial begin
        clock = 1'b0;
        forever begin
            #5 clock = ~clock;
        end
    end

    task automatic send_bit(input logic bit_value);
        begin
            @(negedge clock);
            serial_in = bit_value;
            @(posedge clock);
            #1;
        end   
    endtask 

    task automatic check_detected(input logic expected);
        begin
            if (detected !== expected) begin
                $error("FAIL: serial_in=%b expected detected=%b got=%b history=%b", serial_in, expected, detected, history);
                errors++;
            end
            else begin
                $display("PASS: serial_in=%b detected=%b history=%b", serial_in, detected, history);
            end
        end
    endtask 

    initial begin
        $dumpfile("sequence_detector_1011_tb.vcd");
        $dumpvars(0, test);
        errors = 0;
        reset = 1'b0;
        history = 4'b0000;
        expected_detected = 1'b0;

        file = $fopen("tb/data/input_bits_seq_det.txt", "r");
        if (file == 0) begin
            $fatal(1, "Cannot open input file.");
        end

        reset = 1'b1;
        repeat (2) @(posedge clock);
        reset = 1'b0;

        while (!$feof(file)) begin
            scan_result = $fscanf(file, "%b\n", bit_from_file);
            if (scan_result == 1) begin
                send_bit(bit_from_file);
            end
            history = {history[2:0], bit_from_file};
            expected_detected = (history === 4'b1011);
            check_detected(expected_detected);
        end

        $fclose(file);

        if (errors == 0) begin
            $display("TEST PASSED");
        end
        else begin
            $display("TEST FAILED: errors=%0d", errors);
            $fatal(1);
        end

        $finish;
    end

    always @(negedge clock) begin
        if (reset === 1) begin
            if (detected !== 0) begin
                $error("Fail reset: detected = %b expected = 0", detected);
                errors = errors + 1;
            end
        end  
    end

endmodule