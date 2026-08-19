`timescale 1ns/1ps

import mips_transaction_pkg::*;
import mips_monitor_pkg::*;

module mips_tb;
    logic clock;
    logic reset;

    int errors;
    int unsigned transaction_count = 8;
    int unsigned monitor_count;

    mailbox #(mips_transaction) mon2scr;
    mailbox #(mips_transaction) mon2cov;

    mips_monitor monitor;

    mips_if mips_bus(
        .clock(clock)
    );

    mips_system  #(
    .IMEM_FILE("tb/data/program.hex")
    ) dut (
        .clock (mips_bus.clock),
        .reset (mips_bus.reset)
    );

    assign mips_bus.pc = dut.pc;
    assign mips_bus.instr = dut.instr;

    assign mips_bus.we_mem = dut.mem_write;
    assign mips_bus.wd_mem = dut.write_data;
    assign mips_bus.rd_mem = dut.read_data;
    assign mips_bus.address_mem = dut.alu_result;

    assign mips_bus.we_reg = dut.mips_core.datapath.reg_write;
    assign mips_bus.wa_reg = dut.mips_core.datapath.write_reg;
    assign mips_bus.wd_reg = dut.mips_core.datapath.result;

    initial begin
        clock = 1'b0;
        forever #5 clock = ~clock;
    end
    
    initial begin
        mips_bus.reset = 1'b1;

        repeat (2)
            @(posedge clock);

        #1;
        mips_bus.reset = 1'b0;
    end

    initial begin
        errors = 0;
        mon2scr = new();
        mon2cov = new();
        monitor = new(mips_bus, mon2scr, mon2cov, transaction_count);
        

        $dumpfile("sim/mips_tb.vcd");
        $dumpvars(0, mips_tb);

        monitor.run();
        $display("Monitor finished: observed transactions = %0d",monitor.observed_count);

        $finish;
    end

    initial begin
        #1000;
        $fatal(1, "Timeout");
    end

endmodule