package mips_reference_model_pkg;
    import mips_transaction_pkg::*;

    class mips_reference_model;

        typedef enum {
            OP_LW,
            OP_SW,
            OP_ADD,
            OP_SUB,
            OP_AND,
            OP_OR,
            OP_SLT,
            OP_ADDI,
            OP_BEQ,
            OP_UNKNOWN
        } mips_op;

        logic [31:0] model_pc;
        logic [31:0] model_regs [0:31];
        logic [31:0] model_mem [0:63];


        logic [31:0] expected_pc;
        logic [31:0] expected_next_pc;

        logic        expected_reg_write;
        logic [4:0]  expected_reg_addr;
        logic [31:0] expected_reg_data;

        logic        expected_mem_write;
        logic [31:0] expected_mem_addr;
        logic [31:0] expected_mem_data;

        bit prediction_valid;

        mips_op operation;

        function new();
            reset_model();
            expected_pc = '0;
            expected_next_pc = '0;
            expected_reg_write = 1'b0;
            expected_reg_addr = '0;
            expected_reg_data = '0;
            expected_mem_write = 1'b0;
            expected_mem_addr = '0;
            expected_mem_data = '0;
        endfunction


        function void reset_model();
            model_pc = '0;
            foreach (model_regs[i]) begin
                model_regs[i] = 'x;
            end
            model_regs[0] = '0;
            foreach (model_mem[i]) begin
                model_mem[i] = 'x;
            end
        endfunction


        function automatic logic [31:0] sign_extend16(input logic [15:0] imm);
            return {{16{imm[15]}}, imm};
        endfunction


        function void predict(mips_transaction tr);
            logic [31:0] address;
            logic [31:0] word_index;

            expected_reg_write = 1'b0;
            expected_reg_addr = '0;
            expected_reg_data = '0;
            expected_mem_write = 1'b0;
            expected_mem_addr = '0;
            expected_mem_data = '0;
            expected_pc = model_pc;
            expected_next_pc = model_pc + 32'd4;
            prediction_valid = 1'b1;

            case (tr.opcode)
                6'b000000 : begin
                    case (tr.funct)
                        6'b100000 : operation = OP_ADD;
                        6'b100010 : operation = OP_SUB;
                        6'b100100 : operation = OP_AND;
                        6'b100101 : operation = OP_OR;
                        6'b101010 : operation = OP_SLT;
                        default : operation = OP_UNKNOWN;
                    endcase
                end
                6'b100011 : operation = OP_LW;
                6'b101011 : operation = OP_SW;
                6'b001000 : operation = OP_ADDI;
                6'b000100 : operation = OP_BEQ;
                
                default: operation = OP_UNKNOWN;
            endcase

            case (operation)
                OP_ADD : begin
                    expected_reg_write = 1'b1;
                    expected_reg_addr = tr.rd;
                    expected_reg_data = model_regs[tr.rs] + model_regs[tr.rt];
                    if (tr.rd != '0) begin
                        model_regs[tr.rd] = expected_reg_data; 
                    end
                end
                OP_SUB : begin
                    expected_reg_write = 1'b1;
                    expected_reg_addr = tr.rd;
                    expected_reg_data = model_regs[tr.rs] - model_regs[tr.rt];
                    if (tr.rd != '0) begin
                        model_regs[tr.rd] = expected_reg_data; 
                    end
                end
                OP_AND : begin
                    expected_reg_write = 1'b1;
                    expected_reg_addr = tr.rd;
                    expected_reg_data = model_regs[tr.rs] & model_regs[tr.rt];
                    if (tr.rd != '0) begin
                        model_regs[tr.rd] = expected_reg_data; 
                    end
                end
                OP_OR : begin
                    expected_reg_write = 1'b1;
                    expected_reg_addr = tr.rd;
                    expected_reg_data = model_regs[tr.rs] | model_regs[tr.rt];
                    if (tr.rd != '0) begin
                        model_regs[tr.rd] = expected_reg_data; 
                    end
                end
                OP_SLT : begin
                    expected_reg_write = 1'b1;
                    expected_reg_addr = tr.rd;
                    expected_reg_data = ($signed(model_regs[tr.rs]) < $signed(model_regs[tr.rt]))
                        ? 32'b1
                        : 32'b0;
                    if (tr.rd != '0) begin
                        model_regs[tr.rd] = expected_reg_data; 
                    end
                end
                OP_ADDI : begin
                    expected_reg_write = 1'b1;
                    expected_reg_addr = tr.rt;
                    expected_reg_data = model_regs[tr.rs] + sign_extend16(tr.imm);
                    if (tr.rt != '0) begin
                        model_regs[tr.rt] = expected_reg_data; 
                    end
                end
                OP_LW : begin
                    expected_reg_write = 1'b1;
                    address = model_regs[tr.rs] + sign_extend16(tr.imm);
                    expected_reg_addr = tr.rt;
                    word_index = address >> 2;
                    expected_reg_data = model_mem[word_index];
                    if (tr.rt != '0) begin
                        model_regs[tr.rt] = expected_reg_data; 
                    end
                end
                OP_SW : begin
                    expected_mem_write = 1'b1;
                    expected_mem_addr = model_regs[tr.rs] + sign_extend16(tr.imm);
                    word_index = expected_mem_addr >> 2;
                    expected_mem_data = model_regs[tr.rt];

                    model_mem[word_index] = expected_mem_data; 
                end
                OP_BEQ : begin
                    if (model_regs[tr.rs] == model_regs[tr.rt]) begin
                        expected_next_pc = model_pc + (sign_extend16(tr.imm) << 2) + 32'd4;
                    end
                end
                OP_UNKNOWN : prediction_valid = 1'b0;
                default: begin
                    prediction_valid = 1'b0;
                end
            endcase 
            if (prediction_valid) begin
                model_pc = expected_next_pc;
            end
            
        endfunction

    endclass
endpackage