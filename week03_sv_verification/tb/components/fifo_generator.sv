package fifo_generator_pkg;
    import fifo_transaction_pkg::*;

    class fifo_generator#(
        parameter  int DATA_WIDTH = 8,
        parameter  int DEPTH = 8
    );
        mailbox #(fifo_transaction) outbox;
        int unsigned transaction_counter = 0;
        int unsigned transaction_count;//Оставлю на всякий случай, вдруг в будущем пригодится
        int unsigned write_counter = 0;
        int unsigned read_counter = 0;
        int unsigned rw_counter = 0;
        int unsigned idle_counter = 0;
        int unsigned transaction_count_for_rand = DEPTH * 3;
        int unsigned generated_count = 0;
        int unsigned seed = 12345;
        

        function new(
            mailbox #(fifo_transaction) outbox,
            int unsigned transaction_count
        );
            this.outbox = outbox;
            this.transaction_count = transaction_count;
            void'($urandom(seed));
        endfunction
        
        task run();
            fifo_transaction tr;
            int unsigned i;
            i = 0;

            fifo_ordering();
            full();
            write_while_full();
            write_and_read_while_full();
            empty();
            read_while_empty();
            read_and_write_while_empty();
            read_and_write();
            wrap_around();

            $display("Constrained Random tests.");//Проверка случайным перебором на случай, если есть неучтённый сценарий.
            $display("Seed: %0d", seed);
            $display("Normal");
            constrained_random(25, 25, 25, 25, transaction_count_for_rand);
            $display("Write heavy");
            constrained_random(60, 15, 20, 5, transaction_count_for_rand);
            $display("Read heavy");
            constrained_random(15, 60, 20, 5, transaction_count_for_rand);
            $display("Stress test");
            constrained_random(25, 25, 25, 25, 10000);
        endtask 

        task send_transaction (
            input bit write_en,
            input bit read_en,
            input bit [DATA_WIDTH-1:0] write_data
        );
            fifo_transaction tr;

            tr = new();

            tr.write_en =  write_en;
            tr.read_en =  read_en;
            tr.write_data =  write_data;

            outbox.put(tr);

            generated_count++;
        endtask 

        task directed_test(
            input int unsigned write_chance,
            input int unsigned read_chance,
            input int unsigned tr_count
        );
            bit write_en = 1'b0;
            bit read_en = 1'b0;
            bit [DATA_WIDTH-1:0] write_data;
            for (int i = 0; i < tr_count; i++) begin
                int unsigned rand1;

                write_en = 1'b0;
                read_en = 1'b0;
                write_data = $urandom;
                rand1 = $urandom_range(99, 0);
                if (rand1 < write_chance) begin
                    write_en = 1'b1;
                end
                if (rand1 < read_chance) begin
                    read_en = 1'b1;
                end
                send_transaction(write_en, read_en, write_data);
            end
        endtask

        //Все необходимые сценарии в том числе и те, которые проверяют краевые случаи
        task fifo_ordering();
            $display("Directed: FIFO ordering.");
            directed_test(100, 0, 3);
            directed_test(0, 100, 3);
        endtask
        task full();
            $display("Directed: Full.");
            directed_test(100, 0, DEPTH);
        endtask
        task write_while_full();
            $display("Directed: Write while full.");
            directed_test(100, 0, 1);
        endtask
        task write_and_read_while_full();
            $display("Directed: Write and read while full.");
            directed_test(100, 100, 3);
        endtask
        task empty();
            $display("Directed: Empty.");
            directed_test(0, 100, DEPTH);
        endtask
        task read_while_empty();
            $display("Directed: Read while empty.");
            directed_test(0, 100, 1);
        endtask
        task read_and_write_while_empty();
            $display("Directed: Read and write while empty.");
            directed_test(100, 100, 3);
        endtask
        task read_and_write();
            $display("Directed: Read and write.");
            directed_test(100, 0, 3);
            directed_test(100, 100, 3);
        endtask
        task wrap_around();
            $display("Directed: Wrap around.");
            directed_test(100, 0, DEPTH);
            directed_test(0, 100, 3);
            directed_test(100, 0, 3);
            directed_test(0, 100, DEPTH);
        endtask

        task constrained_random(
            input int unsigned write_chance,
            input int unsigned read_chance,
            input int unsigned rw_chance,
            input int unsigned idle_chance,
            input int unsigned tr_count
            );
            bit write_en;
            bit read_en;
            bit [DATA_WIDTH-1:0] write_data;

            if ((write_chance + read_chance + rw_chance + idle_chance) != 100)
            begin
                $fatal(1, "Random probabilities must sum to 100");
            end

            for (int i = 0; i < tr_count; i++) begin
                int unsigned rand1;

                write_en = 1'b0;
                read_en = 1'b0;
                write_data = $urandom;
                rand1 = $urandom_range(99, 0);
                if (rand1 < write_chance) begin
                    write_en = 1'b1;
                    send_transaction(write_en, read_en, write_data);
                    write_counter++;
                end
                else if (rand1 < (write_chance + read_chance)) begin
                    read_en = 1'b1;
                    send_transaction(write_en, read_en, write_data);
                    read_counter++;
                end
                else if (rand1 < (write_chance + read_chance + rw_chance)) begin
                    read_en = 1'b1;
                    write_en = 1'b1;
                    send_transaction(write_en, read_en, write_data);
                    rw_counter++;
                end
                else begin
                    send_transaction(write_en, read_en, write_data);
                    idle_counter++;
                end
                transaction_counter++;
            end
        endtask

    endclass 
endpackage