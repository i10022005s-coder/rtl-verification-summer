`timescale 1ns/1ps

module test;

    logic [31:0] instr;
    logic [5:0] opcode, funct;
    logic [4:0] rs, rt, rd, shamt;
    logic [15:0] imm;
    logic [31:0] sign_imm;

    int errors;

    instruction_decoder dut_instruction_decoder(
        .instr (instr),
        .opcode (opcode),
        .funct (funct),
        .rs (rs),
        .rt (rt),
        .rd (rd),
        .shamt (shamt),
        .imm (imm),
        .sign_imm (sign_imm)
    );

    task automatic check_r_type(
        input logic [31:0] code,
        input logic [4:0] expected_rs,
        input logic [4:0] expected_rt,
        input logic [4:0] expected_rd,
        input logic [4:0] expected_shamt,
        input logic [5:0] expected_funct
    );
    begin
        instr = code;
        #1;

        if (opcode !== 6'h00) begin
            $error("Wrong opcode: expected=%0d got=%0d", 6'h00, opcode);
            errors++;
        end
        if (rs !== expected_rs) begin
            $error("Wrong rs: expected=%0d got=%0d", expected_rs, rs);
            errors++;
        end
        if (rt !== expected_rt) begin
            $error("Wrong rt: expected=%0d got=%0d", expected_rt, rt);
            errors++;
        end
        if (rd !== expected_rd) begin
            $error("Wrong rd: expected=%0d got=%0d", expected_rd, rd);
            errors++;
        end
        if (shamt !== expected_shamt) begin
            $error("Wrong shamt: expected=%0d got=%0d", expected_shamt, shamt);
            errors++;
        end
        if (funct !== expected_funct) begin
            $error("Wrong funct: expected=%0d got=%0d", expected_funct, funct);
            errors++;
        end
    end
    endtask
    task automatic check_i_type(
        input logic [31:0] code,
        input logic [5:0] expected_opcode,
        input logic [4:0] expected_rs,
        input logic [4:0] expected_rt,
        input logic [15:0] expected_imm,
        input logic [31:0] expected_sign_imm
    );
    begin
        instr = code;
        #1;

        if (opcode !== expected_opcode) begin
            $error("Wrong opcode: expected=%0d got=%0d", expected_opcode, opcode);
            errors++;
        end
        if (rs !== expected_rs) begin
            $error("Wrong rs: expected=%0d got=%0d", expected_rs, rs);
            errors++;
        end
        if (rt !== expected_rt) begin
            $error("Wrong rt: expected=%0d got=%0d", expected_rt, rt);
            errors++;
        end
        if (imm !== expected_imm) begin
            $error("Wrong imm: expected=%0d got=%0d", expected_imm, imm);
            errors++;
        end
        if (sign_imm !== expected_sign_imm) begin
            $error("Wrong sign_imm: expected=%0d got=%0d", expected_sign_imm, sign_imm);
            errors++;
        end
        
    end
    endtask

    initial begin
        $dumpfile("instruction_decoder_tb.vcd");
        $dumpvars(0, test);
        errors = 0;
        instr = '0;

        $display("TEST 1. add");
        check_r_type(32'h012A4020, 9, 10, 8, 0, 6'h20);
        $display("TEST 2. sub");
        check_r_type(32'h018D5822, 12, 13, 11, 0, 6'h22);
        $display("TEST 3. addi");
        check_i_type(32'h21280005, 6'h08, 9, 8, 16'h0005, 32'h0000_0005);
        $display("TEST 4. lw");
        check_i_type(32'h8D280004, 6'h23, 9, 8, 16'h0004, 32'h0000_0004);
        $display("TEST 5. Отрицательное смещение");
        check_i_type(32'hAD6AFFFC, 6'h2B, 11, 10, 16'hFFFC, 32'hFFFF_FFFC);
        $display("TEST 6. Отрицательное смещение перехода");
        check_i_type(32'h1109FFFE, 6'h04, 8, 9, 16'hFFFE, 32'hFFFF_FFFE);
        $display("TEST 7. andi with zero extension");
        check_i_type(32'h3128F0F0, 6'h0C, 5'd9, 5'd8,   16'hF0F0, 32'h0000_F0F0);

        if (errors == 0)
        $display("ALL DECODER TESTS PASSED");
        else
        $fatal(1, "DECODER TEST FAILED: errors=%0d", errors);
        
        $finish;
    end

endmodule