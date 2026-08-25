`timescale 1ns/1ps

import mips_transaction_pkg::*;
import mips_environment_pkg::*;

module mips_tb5;
    logic clock;
    logic reset;

    int errors;
    int unsigned transaction_count = 19;

    mips_environment env;

    mips_if mips_bus(
        .clock(clock)
    );

    mips_system  #(
    .IMEM_FILE("tb/data/program_day5.hex")
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

        $dumpfile("sim/mips_tb5.vcd");
        $dumpvars(0, mips_tb5);

        env = new(mips_bus, transaction_count);
        env.build();
        $display("\tStart MIPS verification\n");
        env.run();
        $finish;
    end

    initial begin
        #3000;
        $fatal(1, "Timeout");
    end

endmodule