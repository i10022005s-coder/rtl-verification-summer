package fifo_scoreboard_pkg;
    import fifo_transaction_pkg::*;

    class fifo_scoreboard #(
        parameter  int DATA_WIDTH = 8,
        parameter  int DEPTH = 8
    );
        int unsigned transaction_count;
        bit model_empty, model_full, do_write, do_read;
        int unsigned checks;
        int unsigned errors;
        bit [DATA_WIDTH-1:0] expected_data;
        bit expected_valid;

        mailbox #(fifo_transaction) inbox;

        logic [DATA_WIDTH-1:0] model_queue[$];
        
        function new(
            mailbox #(fifo_transaction) inbox,
            int unsigned transaction_count
        );
            this.inbox = inbox;
            this.transaction_count = transaction_count;
        endfunction

        task run();
            fifo_transaction tr;
            int unsigned i = 0;
            checks = 0;
            errors = 0;
            model_empty = 1'b1;
            model_full = 1'b0;
            model_queue.delete();
            repeat (transaction_count) begin
                int unsigned errors_in_tr;
                errors_in_tr = 0;

                inbox.get(tr);

                do_write = tr.write_en && !model_full;
                do_read  = tr.read_en && !model_empty;

                expected_valid = 1'b0;
                if (tr.write_en && tr.read_en) begin
                    if (model_empty) begin //Поведение при пустом FIFO
                        expected_data = tr.write_data;
                        expected_valid = 1'b1;
                        if (expected_data !== tr.read_data) begin
                            $error("Error of DUT: read_data = %0d, expected=%0d.", tr.read_data, expected_data);
                            errors_in_tr++;
                        end
                    end
                    else begin //Поведение при полном FIFO здесь учитывается
                        expected_data = model_queue.pop_front();
                        model_queue.push_back(tr.write_data);
                        expected_valid = 1'b1;
                        if (expected_data !== tr.read_data) begin
                            $error("Error of DUT: read_data = %0d, expected=%0d.", tr.read_data, expected_data);
                            errors_in_tr++;
                        end
                    end
                end
                else if(do_write)
                    model_queue.push_back(tr.write_data);
                else if(do_read) begin
                    expected_data = model_queue.pop_front();
                    expected_valid = 1'b1;

                    if (expected_data !== tr.read_data) begin
                        $error("Error of DUT: read_data = %0d, expected=%0d.", tr.read_data, expected_data);
                        errors_in_tr++;
                    end
                end
                

                if (expected_valid !== tr.valid) begin
                    $error("Error of DUT: valid = %0d, expected=%0d.", tr.valid, expected_valid);
                    errors_in_tr++;
                end

                model_empty = (model_queue.size() == 0);
                model_full  = (model_queue.size() == DEPTH);
                
                if (model_empty !== tr.empty) begin
                    $error("Error of DUT: empty = %0d, expected=%0d.", tr.empty, model_empty);
                    errors_in_tr++;
                end
                if (model_full !== tr.full) begin
                    $error("Error of DUT: full = %0d, expected=%0d.", tr.full, model_full);
                    errors_in_tr++;
                end

                if (errors_in_tr !== 0)
                    errors++;
                checks++;
            end

            if(errors == 0) begin
                $display("Tests complete: checks = %0d, errors = 0.", checks);
            end
            else begin
                $display("Tests complete: checks = %0d, errors = %0d.", checks, errors);
            end
        endtask 

    endclass 
endpackage