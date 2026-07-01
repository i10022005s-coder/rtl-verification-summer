`timescale 1ns/1ps

module test;

    logic d1, serial_in, clock, reset, enable, q1;
    logic [3:0] d, q_register_en, q_shift_register, count;

    int errors;
    logic [3:0] pre_q_register_en;
    logic [3:0] pre_q_shift_register;
    logic [3:0] pre_count;

    dff dut_dff(
        .d(d1),
        .clock (clock),
        .reset (reset),
        .q (q1)
    );
    register_en dut_register_en(
        .d(d),
        .clock (clock),
        .reset (reset),
        .enable (enable),
        .q (q_register_en)
    );
    shift_register dut_shift_register(
        .clock (clock),
        .reset (reset),
        .enable (enable),
        .serial_in (serial_in),
        .q (q_shift_register) 
    );
    counter_modN dut_counter_modN(
        .clock (clock),
        .reset (reset),
        .enable (enable),
        .count (count)
    );

    always  begin
        clock = 1; #5;
        clock = 0; #5;
    end

    initial begin
        errors = 0;
        pre_q_register_en = '0;
        pre_q_shift_register = '0;
        pre_count = '0;

        reset = 1'b1;
        enable = 1'b1; #10;
        reset = 1'b0; 
        d1 = 1'b1; #10;
        d1 = 1'b0; #10;
        d1 = 1'b1; #10;
        reset = 1'b1; #10;
        if (errors == 0) begin
            $display("DFF is coreect.");
        end
        else begin
            $display("DFF is uncorrect.");
        end
        errors = 0;

        reset = 1'b0; #10;
        d = 4'b1010; #10;
        if (q_register_en !== d) begin
            $error("Fail register_en: q = %b expected = %b", q_register_en, d);
                errors = errors + 1;
        end
        #10;
        d = 4'b1000; #10
        enable = 1'b0; #20;
        reset = 1'b1; #10;
        if (errors == 0) begin
            $display("register_en is coreect.");
        end
        else begin
            $display("register_en is uncorrect.");
        end
        errors = 0;

        serial_in = 1'b0; 
        enable = 1'b1;
        reset = 1'b0; #10;
        serial_in = 1'b1; #5;
        if (q_shift_register !== 4'b0001) begin
            $error("Fail shift_register: q = %b expected = %b", q_shift_register, 4'b0001);
                errors = errors + 1;
        end
        #5;
        serial_in = 1'b0; #5;
        if (q_shift_register !== 4'b0010) begin
            $error("Fail shift_register: q = %b expected = %b", q_shift_register, 4'b0001);
                errors = errors + 1;
        end
        #5;
        enable = 1'b0;
        serial_in = 1'b0; #10;
        serial_in = 1'b1; #10;
        enable = 1'b1;
        serial_in = 1'b1; #5;
        if (q_shift_register !== 4'b0101) begin
            $error("Fail shift_register: q = %b expected = %b", q_shift_register, 4'b0001);
            errors = errors + 1;
        end
        #5;
        reset = 1'b1; #10;
        if (errors == 0) begin
            $display("shift_register is coreect.");
        end
        else begin
            $display("shift_register is uncorrect.");
        end
        errors = 0;

        reset = 1'b0;
        for (int i = 0; i < 10; i++) begin
            if (count !== i) begin
                $error("Fail counter: count = %b expected = %b", q_shift_register, i);
                errors = errors + 1;
            end
            @(posedge clock);
            #1;
        end
        if (count !== 0) begin
            $error("Fail counter: count = %b expected = 0", count);
            errors = errors + 1;
        end
        if (errors == 0) begin
            $display("counter is coreect.");
        end
        else begin
            $display("counter is uncorrect.");
        end


        $finish;
    end

    always @(negedge clock) begin
        if (reset === 1) begin
            if (q1 !== 0) begin
                $error("Fail dff: q = %b expected = 0", q1);
                errors = errors + 1;
            end
            if (q_register_en !== 0) begin
                $error("Fail register_en: q = %b expected = 0", q_register_en);
                errors = errors + 1;
            end
            if (q_shift_register !== 0) begin
                $error("Fail shift_register: q = %b expected = 0", q_shift_register);
                errors = errors + 1;
            end
            if (count !== 0) begin
                $error("Fail count: count = %b expected = 0", count);
                errors = errors + 1;
            end
        end
        else begin
            if (q1 !== d1) begin
                $error("Fail: q = %b expected = %b", q1, d1);
                errors = errors + 1;
            end
            if (enable !== 1) begin
                if (q_register_en !== pre_q_register_en) begin
                    $error("Fail register_en: reset = %b, enable = %b q = %b expected = %b", reset, enable, q_register_en, pre_q_register_en);
                    errors = errors + 1;
                end
                if (q_shift_register !== pre_q_shift_register) begin
                    $error("Fail shift_register: reset = %b, enable = %b q = %b expected = %b", reset, enable, q_shift_register, pre_q_shift_register);
                    errors = errors + 1;
                end
                if (count !== pre_count) begin
                    $error("Fail count: reset = %b, enable = %b count = %b expected = %b", reset, enable, count, pre_count);
                    errors = errors + 1;
                end
            end
        end
        pre_q_register_en = q_register_en;
        pre_q_shift_register = q_shift_register;
        pre_count = count;
    end

endmodule