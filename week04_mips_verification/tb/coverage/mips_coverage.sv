package mips_coverage_pkg;
    import mips_transaction_pkg::*;

    class mips_coverage;

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

        mailbox #(mips_transaction) inbox;
        int unsigned transaction_count;
        int unsigned sampled_count;

        logic [31:0] pc_after, pc_before;
        logic [15:0] imm;
        logic [4:0] rt,  rd;
        logic [5:0] opcode;
        mips_op operation;
        logic beq_take;
        logic sign, zero, zero_reg;

        covergroup mips_cg;
            cp_operation : coverpoint operation {
                bins lw = {OP_LW};
                bins sv = {OP_SW};
                bins add = {OP_ADD};
                bins sub = {OP_SUB};
                bins and = {OP_AND};
                bins or = {OP_OR};
                bins slt = {OP_SLT};
                bins addi = {OP_ADDI};
                bins beq = {OP_BEQ};
                ignore_bins unknown = {OP_UNKNOWN};
            }
            cp_beq_outcome : coverpoint beq_take iff (operation == OP_BEQ){
                bins taken = {1};
                bins not_taken = {0};
            }
            cp_imm_class : coverpoint {sign, zero} iff (operation inside {OP_ADDI, OP_LW, OP_SW, OP_BEQ}) {
                bins neg = {1'b0, 1'b0};
                bins pos = {1'b1, 1'b0};
                bins zero = {1'b1, 1'b1};
            }
            cp_destination_register : coverpoint zero_reg {
                bins zero = {1'b1};
                bins not_zero = {1'b0};
            }
            cp_mem_operation : coverpoint operation {
                bins lw = {OP_LW};
                bins sw = {OP_SW};
            }
            cp_mem_address : coverpoint (imm == '0) {
                bins not_zero = {1'b0};
                bins zero = {1'b1};
            }

            mem_x_address :
                cross cp_mem_operation, cp_mem_address;
        endgroup

        function new(
            mailbox #(mips_transaction) inbox,
            int unsigned transaction_count
        );
            this.inbox = inbox;
            this.transaction_count = transaction_count;
            sampled_count = 0;
            mips_cg = new();
        endfunction
        
        task run();
            mips_transaction tr;
            
            repeat (transaction_count) begin
                inbox.get(tr);
                
                pc_after = tr.pc_after;
                pc_before = tr.pc_before;
                imm = tr.imm;
                rt = tr.rt;
                rd = tr.rd;
                opcode = tr.opcode;
                operation = tr.operation;
                
                sign = (imm[15] == 1'b0);
                zero = (imm == '0);
                zero_reg = ((opcode == '0) & (rd == '0)) | (((operation == OP_ADDI) | (operation == OP_LW)) & (rt == '0));

                mips_cg.sample();

                sampled_count++;
            end
        endtask 

        function void report();
            $display("Coverage = %0.2f", mips_cg.get_inst_coverage());
        endfunction

    endclass 
endpackage