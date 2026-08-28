package mips_coverage_pkg;

    import mips_transaction_pkg::*;

    class mips_coverage;

        mailbox #(mips_transaction) inbox;

        int unsigned transaction_count;
        int unsigned sampled_count;


        mips_transaction::mips_op operation;


        bit beq_taken;

        bit imm_negative;
        bit imm_zero;

        bit write_zero_reg;

        bit mem_zero_address;



        int unsigned operation_count[10];

        int unsigned beq_count[2];

        int unsigned imm_count[3];

        int unsigned zero_reg_count[2];

        int unsigned mem_address_count[2];



        function new(
            mailbox #(mips_transaction) inbox,
            int unsigned transaction_count
        );

            this.inbox = inbox;
            this.transaction_count = transaction_count;

            sampled_count = 0;


            for(int i = 0; i < 10; i++)
                operation_count[i] = 0;

            for(int i = 0; i < 2; i++) begin
                beq_count[i] = 0;
                zero_reg_count[i] = 0;
                mem_address_count[i] = 0;
            end


            for(int i = 0; i < 3; i++)
                imm_count[i] = 0;


        endfunction



        task run();

            mips_transaction tr;


            repeat(transaction_count) begin

                inbox.get(tr);

                operation = tr.operation;

                operation_count[operation]++;

                if(operation == mips_transaction::OP_BEQ) begin

                    if(tr.pc_after != tr.pc_before + 4)
                        beq_taken = 1;
                    else
                        beq_taken = 0;


                    beq_count[beq_taken]++;

                end

                if(operation inside 
                   {mips_transaction::OP_ADDI, mips_transaction::OP_LW, mips_transaction::OP_SW, mips_transaction::OP_BEQ}) begin


                    if(tr.imm == 0)
                        imm_count[0]++;          

                    else if(tr.imm[15])
                        imm_count[1]++;          

                    else
                        imm_count[2]++;          

                end

                write_zero_reg = 0;


                if(tr.we_reg) begin

                    if(tr.wa_reg == 0)
                        write_zero_reg = 1;

                end


                zero_reg_count[write_zero_reg]++;


                if(operation inside {mips_transaction::OP_LW, mips_transaction::OP_SW}) begin


                    if(tr.address_mem == 0)
                        mem_address_count[1]++;

                    else
                        mem_address_count[0]++;

                end



                sampled_count++;

            end


        endtask



        function real get_coverage();


            int total = 0;
            int covered = 0;

            total += 9;

            for(int i = 0; i < 9; i++)
                if(operation_count[i] != 0)
                    covered++;

            total += 2;

            for(int i = 0; i < 2; i++)
                if(beq_count[i] != 0)
                    covered++;

            total += 3;

            for(int i = 0; i < 3; i++)
                if(imm_count[i] != 0)
                    covered++;

            total += 2;

            for(int i = 0; i < 2; i++)
                if(zero_reg_count[i] != 0)
                    covered++;

            total += 2;

            for(int i = 0; i < 2; i++)
                if(mem_address_count[i] != 0)
                    covered++;



            return 100.0 * covered / total;


        endfunction



        task report();


            $display("");
            $display("==============================");
            $display(" MIPS FUNCTIONAL COVERAGE ");
            $display("==============================");


            $display("");

            $display("Operations:");

            $display(" LW    : %0d", operation_count[mips_transaction::OP_LW]);
            $display(" SW    : %0d", operation_count[mips_transaction::OP_SW]);
            $display(" ADD   : %0d", operation_count[mips_transaction::OP_ADD]);
            $display(" SUB   : %0d", operation_count[mips_transaction::OP_SUB]);
            $display(" AND   : %0d", operation_count[mips_transaction::OP_AND]);
            $display(" OR    : %0d", operation_count[mips_transaction::OP_OR]);
            $display(" SLT   : %0d", operation_count[mips_transaction::OP_SLT]);
            $display(" ADDI  : %0d", operation_count[mips_transaction::OP_ADDI]);
            $display(" BEQ   : %0d", operation_count[mips_transaction::OP_BEQ]);



            $display("");

            $display("BEQ:");

            $display(" Taken     : %0d", beq_count[1]);
            $display(" Not taken : %0d", beq_count[0]);



            $display("");

            $display("Immediate:");

            $display(" Zero     : %0d", imm_count[0]);
            $display(" Negative : %0d", imm_count[1]);
            $display(" Positive : %0d", imm_count[2]);



            $display("");

            $display("Register:");

            $display(" Write $zero : %0d", zero_reg_count[1]);
            $display(" Normal      : %0d", zero_reg_count[0]);



            $display("");

            $display("Memory:");

            $display(" Non-zero address : %0d", mem_address_count[0]);
            $display(" Zero address     : %0d", mem_address_count[1]);



            $display("");

            $display("Total coverage = %0.2f %%", get_coverage());

            $display("==============================");

        endtask



    endclass


endpackage