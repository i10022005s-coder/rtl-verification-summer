`timescale 1ns/1ps

module test;

    logic clock, reset;
    logic [31:0] next_pc, pc_unit, pc;
    logic select;
    logic [31:0] d0, d1, mux2_result;
    logic [31:0] a, b;
    logic [2:0] alu_control;
    logic [31:0] result_alu;
    logic zero_unit, zero;
    logic [31:0] alu_result;
    logic mem_to_reg, pc_src, alu_src, reg_dst, reg_write;
    logic [31:0] instr;
    logic [5:0] opcode, funct;
    logic [4:0] shamt;
    logic [31:0] write_data, read_data;

    int errors;

    pc_reg dut_pc_reg(
        .clock (clock),
        .reset (reset),
        .next_pc (next_pc),
        .pc (pc_unit)
    );
    mux2 dut_mux2(
        .d0 (d0),
        .d1 (d1),
        .select (select),
        .result (mux2_result)
    );
    mips_alu dut_mips_alu(
        .a (a),
        .b (b),
        .alu_control (alu_control),

        .result (result_alu),
        .zero (zero_unit)
    );  
    datapath dut_datapath(
        .clock (clock),
        .reset (reset),

        .mem_to_reg (mem_to_reg),
        .pc_src (pc_src),
        .alu_src (alu_src),
        .reg_dst (reg_dst),
        .reg_write (reg_write),
        .alu_control (alu_control),

        .zero (zero),
        .pc (pc),

        .instr (instr),
        .opcode (opcode),
        .shamt (shamt),
        .funct (funct),

        .alu_result (alu_result),
        .write_data (write_data),
        .read_data (read_data)
    );

    
    task automatic check_mips_alu(
        input logic [31:0] ain,
        input logic [31:0] bin,
        input logic [2:0] alu_control_in,
        input logic [31:0] expected_result,
        input logic expected_zero
    );
    begin
        a = ain;
        b = bin;
        alu_control = alu_control_in;
        #1;

        if ((result_alu !== expected_result) || (zero_unit !== expected_zero)) begin
            $error("Wrong result_alu: expected_result=%0d got=%0d; expected_zero=%0d got=%0d", expected_result, result_alu, expected_zero, zero_unit);
            errors++;
        end
        
    end
    endtask

    initial begin
        clock = 1'b0;
        forever begin
            #5 clock = ~clock;
        end
    end

    initial begin
        $dumpfile("sim/datapath_tb.vcd");
        $dumpvars(0, test);
        errors = 0;
        next_pc = '0;
        pc_src = '0;
        alu_src = '0;
        reg_dst = '0;
        reg_write = '0;
        alu_control = '0;
        instr = '0;
        read_data = '0;

        reset = 1'b1;
        repeat (2) @(posedge clock); #1;
        reset = 1'b0;
        @(posedge clock);

        $display("Check pc_reg.");
        $display("Test 1. Асинхронный reset.");
        @(negedge clock);
        reset = 1'b1; #1;
        if (pc_unit !== '0) begin
            $error("pc_reg: pc=%h expected=%h", pc_unit, '0);
            errors++;
        end
        $display("Test 2. Запись pc_reg.");
        reset = 1'b0;
        #1;
        next_pc = 32'd32;
        @(posedge clock); #1;
        if (pc_unit !== 32'd32) begin
            $error("pc_reg: pc=%h expected=%h", pc_unit, next_pc);
            errors++;
        end
        $display("Test 3. Удержание до следующего фронта.");
        #1;
        next_pc = 32'd31;
        #1;
        if (pc_unit !== 32'd32) begin
            $error("pc_reg: pc=%h expected=%h", pc_unit, 32'd32);
            errors++;
        end
        if (errors == 0)
        $display("ALL pc_reg TESTS PASSED");
        else
        $fatal(1, "pc_reg FAILED: errors=%0d", errors);
        errors = 0;

        $display("Check mux2.");
        d0 = 32'h1234_5678;
        d1 = 32'hDEAD_BEEF;
        select = 1'b0; #1;
        if (mux2_result !== 32'h1234_5678) begin
            $error("mux2_result: select=%h mux2_result=%h expected=%h", select, mux2_result, 32'h1234_5678);
            errors++;
        end
        #1; select = 1'b1; #1;
        if (mux2_result !== 32'hDEAD_BEEF) begin
            $error("mux2_result: select=%h mux2_result=%h expected=%h", select, mux2_result, 32'hDEAD_BEEF);
            errors++;
        end
        if (errors == 0)
        $display("ALL mux2 TESTS PASSED");
        else
        $fatal(1, "mux2 FAILED: errors=%0d", errors);
        errors = 0;

        $display("Check mips_alu.");
        $display("Test 1. AND.");
        check_mips_alu(32'hF0F0_00FF, 32'h0FF0_F00F, 3'b000, 32'h00F0_000F, 0);
        $display("Test 2. OR.");
        check_mips_alu(32'hF000_000F, 32'h00F0_00F0, 3'b001, 32'hF0F0_00FF, 0);
        $display("Test 3. ADD.");
        check_mips_alu(15, 27, 3'b010, 42, 0);
        $display("Test 4. SUB.");
        check_mips_alu(27, 15, 3'b110, 12, 0);
        $display("Test 5. SLT, истина.");
        check_mips_alu(-1, 1, 3'b111, 1, 0);
        $display("Test 6. SLT, ложь.");
        check_mips_alu(5, -2, 3'b111, 0, 1);
        if (errors == 0)
        $display("ALL mips_alu TESTS PASSED");
        else
        $fatal(1, "mips_alu FAILED: errors=%0d", errors);
        errors = 0;

        $display("Check datapath.");
        $display("Test 1. reset.");
        reset = 1'b1;
        repeat (2) @(posedge clock); #1;
        reset = 1'b0;
        #1;
        if (pc !== '0) begin
            $error("datapath: pc=%0d expected=%0d", pc, '0);
            errors++;
        end
        $display("Test 2. Последовательное изменение PC.");
        @(posedge clock); #1;
        if (pc !== 4) begin
            $error("datapath: pc=%0d expected=%0d", pc, 4);
            errors++;
        end
        @(posedge clock); #1;
        if (pc !== 8) begin
            $error("datapath: pc=%0d expected=%0d", pc, 8);
            errors++;
        end
        @(posedge clock); #1;
        if (pc !== 12) begin
            $error("datapath: pc=%0d expected=%0d", pc, 12);
            errors++;
        end
        $display("Test 3. Переход вперёд.");
        pc_src = 1'b1;
        instr = {6'h04, 5'd0, 5'd0, 16'd2};
        @(posedge clock); #1;
        if (pc !== 24) begin
            $error("datapath: pc=%0d expected=%0d", pc, 24);
            errors++;
        end
        $display("Test 4. Переход назад.");
        pc_src = 1'b1;
        instr = {6'h04, 5'd0, 5'd0, 16'hFFFE};
        @(posedge clock); #1;
        if (pc !== 20) begin
            $error("datapath: pc=%0d expected=%0d", pc, 20);
            errors++;
        end
        $display("Test 5. Проверка addi.");
        instr = {6'h08, 5'd0, 5'd1, 16'd5};
        reg_write  = 1'b1;
        reg_dst    = 1'b0;
        alu_src    = 1'b1;
        mem_to_reg = 1'b0;
        alu_control = 3'b010;
        #1;
        if (alu_result !== 32'd5) begin
            $error("datapath: alu_result=%0d expected=%0d", alu_result, 5);
            errors++;
        end
        @(posedge clock); #1;
        $display("Test 6. Проверка пути sw и чтения регистра.");
        instr = {6'h2B, 5'd0, 5'd1, 16'd12};
        reg_write  = 1'b0;
        reg_dst    = 1'b0;
        alu_src    = 1'b1;
        mem_to_reg = 1'b0;
        alu_control = 3'b010;
        #1;
        if (alu_result !== 32'd12) begin
            $error("datapath: alu_result=%0d expected=%0d", alu_result, 12);
            errors++;
        end
        if (write_data !== 32'd5) begin
            $error("datapath: write_data=%0d expected=%0d", write_data, 5);
            errors++;
        end
        #1;
        $display("Test 7. Проверка lw.");
        @(negedge clock);
        instr = {6'h23, 5'd0, 5'd2, 16'd4};
        read_data = 32'hDEAD_BEEF;
        reg_write   = 1'b1;
        reg_dst     = 1'b0;
        alu_src     = 1'b1;
        mem_to_reg  = 1'b1;
        alu_control = 3'b010;
        #1;
        if (alu_result !== 32'd4) begin
            $error("datapath: alu_result=%0d expected=%0d", alu_result, 4);
            errors++;
        end
        @(posedge clock); #1;
        @(negedge clock);
        instr = {6'h2B, 5'd0, 5'd2, 16'd8};
        reg_write  = 1'b0;
        reg_dst    = 1'b0;
        alu_src    = 1'b1;
        mem_to_reg = 1'b0;
        alu_control = 3'b010;
        #1;
        if (alu_result !== 32'd8) begin
            $error("datapath: alu_result=%0d expected=%0d", alu_result, 8);
            errors++;
        end
        if (write_data !== 32'hDEAD_BEEF) begin
            $error("datapath: write_data=%h expected=%h", write_data, 32'hDEAD_BEEF);
            errors++;
        end
        $display("Test 8. Проверка R-type и reg_dst.");
        @(negedge clock);
        instr = {6'h00, 5'd1, 5'd2, 5'd3, 5'd0, 6'h20};
        reg_write   = 1'b1;
        reg_dst     = 1'b1;
        alu_src     = 1'b0;
        mem_to_reg  = 1'b0;
        alu_control = 3'b010;
        @(posedge clock); #1;
        @(negedge clock);
        instr = {6'h2B, 5'd0, 5'd3, 16'd12};
        reg_write  = 1'b0;
        reg_dst    = 1'b0;
        alu_src    = 1'b1;
        mem_to_reg = 1'b0;
        alu_control = 3'b010;
        #1;
        if (alu_result !== 32'd12) begin
            $error("datapath: alu_result=%0d expected=%0d", alu_result, 12);
            errors++;
        end
        if (write_data !== 32'hDEAD_BEF4) begin
            $error("datapath: write_data=%h expected=%h", write_data, 32'hDEAD_BEF4);
            errors++;
        end
        $display("Test 9. Проверка reg_write = 0.");
        @(negedge clock);
        instr = {6'h08, 5'd0, 5'd4, 16'd10};
        reg_write  = 1'b1;
        reg_dst    = 1'b0;
        alu_src    = 1'b1;
        mem_to_reg = 1'b0;
        alu_control = 3'b010;
        @(posedge clock); #1;
        @(negedge clock);
        instr = {6'h00, 5'd1, 5'd2, 5'd4, 5'd0, 6'h20};
        reg_write   = 1'b0;
        reg_dst     = 1'b1;
        alu_src     = 1'b0;
        mem_to_reg  = 1'b0;
        alu_control = 3'b010;
        @(posedge clock); #1;
        @(negedge clock);
        instr = {6'h2B, 5'd0, 5'd4, 16'd12};
        reg_write  = 1'b0;
        reg_dst    = 1'b0;
        alu_src    = 1'b1;
        mem_to_reg = 1'b0;
        alu_control = 3'b010;
        #1;
        if (write_data !== 32'd10) begin
            $error("datapath: write_data=%h expected=%h", write_data, 32'd10);
            errors++;
        end
        $display("Test 10. Проверка нулевого регистра.");
        @(negedge clock);
        instr = {6'h08, 5'd0, 5'd0, 16'd123};
        reg_write  = 1'b1;
        reg_dst    = 1'b0;
        alu_src    = 1'b1;
        mem_to_reg = 1'b0;
        alu_control = 3'b010;
        @(posedge clock); #1;
        @(negedge clock);
        instr = {6'h2B, 5'd0, 5'd0, 16'd12};
        reg_write  = 1'b0;
        reg_dst    = 1'b0;
        alu_src    = 1'b1;
        mem_to_reg = 1'b0;
        alu_control = 3'b010;
        #1;
        if (write_data !== 32'd0) begin
            $error("datapath: write_data=%h expected=%h", write_data, 32'd0);
            errors++;
        end
        $display("Test 11. Проверка zero.");
        @(negedge clock);
        instr = {6'h00,5'd1,5'd1,5'd5,5'd0,6'h22};
        pc_src      = 1'b0;
        reg_write   = 1'b0;
        reg_dst     = 1'b1;
        alu_src     = 1'b0;
        mem_to_reg  = 1'b0;
        alu_control = 3'b110;
        #1;
        if (alu_result !== 32'd0) begin
            $error("zero test: alu_result=%h expected=%h",alu_result,32'd0);
            errors++;
        end
        if (zero !== 1'b1) begin
            $error("zero test: zero=%b expected=1",zero);
            errors++;
        end
        instr = {6'h00,5'd1,5'd0,5'd5,5'd0,6'h22};
        #1;
        if (alu_result !== 32'd5) begin
        $error("nonzero test: alu_result=%h expected=%h",alu_result,32'd5);
        errors++;
        end
        if (zero !== 1'b0) begin
            $error("nonzero test: zero=%b expected=0", zero);
            errors++;
        end
        if (errors == 0) begin
            $display("ALL DATAPATH TESTS PASSED");
        end
        else begin
            $fatal(1, "DATAPATH TESTS FAILED: errors=%0d", errors);
        end

        $finish;
    end

endmodule