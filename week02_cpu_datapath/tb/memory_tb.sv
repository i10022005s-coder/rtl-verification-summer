`timescale 1ns/1ps

module test;

    logic clock, we;
    logic [31:0] instr_addr;
    logic [31:0] data_addr;
    logic [31:0] instr;
    logic [31:0] wd;
    logic [31:0] rd;

    int errors = 0;
    logic [31:0] old_data;

    instr_mem dut_instr_mem(
        .addr (instr_addr),
        .instr (instr)
    );
    data_mem dut_data_mem(
        .clock (clock),
        .we (we),
        .addr (data_addr),
        .wd (wd),
        .rd (rd)
    );

    initial begin
        clock = 1'b0;
        forever begin
            #5 clock = ~clock;
        end
    end

    task automatic check_instr(logic [31:0] addr_value, logic [31:0] expected);
    begin
        instr_addr = addr_value; 
        #1;
        if (instr !== expected) begin
            $error("Instruction memory error: addr = %0d, expected = %h, got = %h.", addr_value, expected, instr);
            errors++;
        end
    end
    endtask 
    task automatic write_data(logic [31:0] addr_value, logic [31:0] data_value);
    begin
        @(negedge clock);
        we = 1'b1;
        data_addr = addr_value;
        wd = data_value;
        @(negedge clock);
        we = 1'b0;
        wd = '0;
    end
    endtask 

    initial begin
        $dumpfile("memory_tb.vcd");
        $dumpvars(0, test);
        errors = 0;
        we = '0;
        instr_addr = '0;
        data_addr = '0;
        wd = '0;

        $display("Check Instruction memory");
        check_instr(0, 32'h12345678);
        check_instr(4, 32'hAABBCCDD);
        check_instr(8, 32'h00000001);
        check_instr(12, 32'hDEADBEEF);
        check_instr(16, 32'hCAFEBABE);
        if (errors == 0) begin
            $display("Test passed");
        end
        else begin
            $display("Test failed");
        end
        errors = 0;

        $display("Check Data memory.");
        $display("Test 1.");
        write_data(12, 32'hDEADDEAD);
        if (rd !== 32'hDEADDEAD) begin
            $error("Data memory error: addr = %0d, expected = %h, got = %h.", data_addr, 32'hDEADDEAD, rd);
        end
        old_data = rd;
        $display("Test 2.");
        write_data(16, 32'hDEADBEDD);
        if ((rd !== 32'hDEADBEDD) || (old_data === rd)) begin
            $error("Data memory error: addr = %0d, expected = %h, old_data = %h, got = %h.", data_addr, 32'hDEADBEDD, old_data, rd);
        end
        $display("Test 3.");
        @(negedge clock);
        we = 1'b0;
        data_addr = '0;
        wd = 32'hCAFEBABE;
        @(posedge clock); #1;
        if (rd != 32'hxxxxxxxx) begin
            $error("Data memory error: addr = %0d, expected = %h, got = %h.", data_addr, 32'hxxxxxxxx, rd);
        end


        $finish;
    end


endmodule