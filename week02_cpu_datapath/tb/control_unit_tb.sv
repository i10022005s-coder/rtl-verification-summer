`timescale 1ns/1ps

module test;

    logic [5:0] opcode, funct;
    logic mem_to_reg, mem_write, branch, alu_src, reg_dst, reg_write;
    logic [1:0] alu_op;
    logic [2:0] alu_control;

    int errors;

    main_decoder dut_main_decoder(
        .opcode (opcode),
        .mem_to_reg (mem_to_reg),
        .mem_write (mem_write),
        .branch (branch),
        .alu_src (alu_src),
        .reg_dst (reg_dst),
        .reg_write (reg_write),
        .alu_op (alu_op)
    );
    alu_decoder dut_alu_decoder(
        .funct (funct),
        .alu_op (alu_op),
        .alu_control (alu_control)
    );

    
    task automatic check_control_unit(
        input logic [5:0] opcode_in,
        input logic [5:0] funct_in,

        input logic expected_mem_to_reg,
        input logic expected_mem_write,
        input logic expected_branch,
        input logic expected_alu_src,
        input logic expected_reg_dst,
        input logic expected_reg_write,
        input logic [1:0] expected_alu_op,
        input logic [2:0] expected_alu_control
    );
    begin
        opcode = opcode_in;
        funct = funct_in;
        #1;

        if (mem_to_reg !== expected_mem_to_reg) begin
            $error("Wrong mem_to_reg: expected=%0d got=%0d", expected_mem_to_reg, mem_to_reg);
            errors++;
        end
        if (mem_write !== expected_mem_write) begin
            $error("Wrong mem_write: expected=%0d got=%0d", expected_mem_write, mem_write);
            errors++;
        end
        if (branch !== expected_branch) begin
            $error("Wrong branch: expected=%0d got=%0d", expected_branch, branch);
            errors++;
        end
        if (alu_src !== expected_alu_src) begin
            $error("Wrong alu_src: expected=%0d got=%0d", expected_alu_src, alu_src);
            errors++;
        end
        if (reg_dst !== expected_reg_dst) begin
            $error("Wrong reg_dst: expected=%0d got=%0d", expected_reg_dst, reg_dst);
            errors++;
        end
        if (reg_write !== expected_reg_write) begin
            $error("Wrong reg_write: expected=%0d got=%0d", expected_reg_write, reg_write);
            errors++;
        end
        if (alu_op !== expected_alu_op) begin
            $error("Wrong alu_op: expected=%0d got=%0d", expected_alu_op, alu_op);
            errors++;
        end
        if (alu_control !== expected_alu_control) begin
            $error("Wrong alu_control: expected=%0d got=%0d", expected_alu_control, alu_control);
            errors++;
        end
    end
    endtask

    initial begin
        $dumpfile("sim/control_unit_tb.vcd");
        $dumpvars(0, test);
        errors = 0;

        $display("TEST 1. R-type comands:");
        $display("ADD");
        check_control_unit(6'b000000, 6'b100000, 0, 0, 0, 0, 1, 1, 2'b10, 3'b010);
        $display("SUB");
        check_control_unit(6'b000000, 6'b100010, 0, 0, 0, 0, 1, 1, 2'b10, 3'b110);
        $display("AND");
        check_control_unit(6'b000000, 6'b100100, 0, 0, 0, 0, 1, 1, 2'b10, 3'b000);
        $display("OR");
        check_control_unit(6'b000000, 6'b100101, 0, 0, 0, 0, 1, 1, 2'b10, 3'b001);
        $display("SLT");
        check_control_unit(6'b000000, 6'b101010, 0, 0, 0, 0, 1, 1, 2'b10, 3'b111);
        $display("TEST 2. LW");
        check_control_unit(6'b100011, 6'b000000, 1, 0, 0, 1, 0, 1, 2'b00, 3'b010);
        $display("TEST 3. SW");
        check_control_unit(6'b101011, 6'b000000, 0, 1, 0, 1, 0, 0, 2'b00, 3'b010);
        $display("TEST 4. BEQ");
        check_control_unit(6'b000100, 6'b000000, 0, 0, 1, 0, 0, 0, 2'b01, 3'b110);
        $display("TEST 5. ADDI");
        check_control_unit(6'b001000, 6'b000000, 0, 0, 0, 1, 0, 1, 2'b00, 3'b010);
        $display("TEST 6. UNKNOWN CODE");
        check_control_unit(6'b111111, 6'b000000, 0, 0, 0, 0, 0, 0, 2'b00, 3'b010);
        
        if (errors == 0)
        $display("ALL CONTROL UNIT TESTS PASSED");
        else
        $fatal(1, "CONTROL UNIT FAILED: errors=%0d", errors);
        
        $finish;
    end

endmodule