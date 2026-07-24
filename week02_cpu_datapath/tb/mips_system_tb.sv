`timescale 1ns/1ps

module test;

    logic clock, reset;

    int errors;

    mips_system #(
        .IMEM_FILE("tb/data/program.hex")
    ) dut_mips_system(
    .clock (clock),
    .reset (reset)
    );

    initial begin
        clock = 1'b0;
        forever begin
            #5 clock = ~clock;
        end
    end

    logic visited_pc24;

    initial begin
        visited_pc24 = 1'b0;
    end

    always @(negedge clock) begin
        if (!reset && (dut_mips_system.pc === 32'd24)) begin
            visited_pc24 = 1'b1;
        end
    end

    initial begin
        $dumpfile("sim/mips_system_tb.vcd");
        $dumpvars(0, test);
        errors = 0;

        $display("TEST mips_system:");
        reset = 1'b1;
        repeat (2) @(posedge clock); #1;
        reset = 1'b0;
        @(posedge clock);

        repeat (9) @(posedge clock); #1;
        if (visited_pc24) begin
            $error("Branch failed: instruction at PC=24 was executed");
            errors++;
        end
        if (dut_mips_system.data_mem.mem[0] !== 32'd12) begin
            $error("data memory: mem[0] = %0d, expected = 12", dut_mips_system.data_mem.mem[0]);
            errors++;
        end
        if (dut_mips_system.data_mem.mem[1] !== 32'd42) begin
            $error("data memory: mem[1] = %0d, expected = 42", dut_mips_system.data_mem.mem[1]);
            errors++;
        end
        
        if (errors == 0)
        $display("ALL MIPS SYSTEM TESTS PASSED");
        else
        $fatal(1, "MIPS SYSTEM FAILED: errors=%0d", errors);
        
        $finish;
    end

endmodule