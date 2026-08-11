package fifo_generator_pkg;
    import fifo_transaction_pkg::*;

    class fifo_generator#(
        parameter  int DATA_WIDTH = 8,
        parameter  int DEPTH = 8
    );
        mailbox #(fifo_transaction) outbox;
        int unsigned transaction_count; //Оставлю на всякий случай, вдруг в будущем пригодится
        int unsigned transaction_count_for_rand = DEPTH * 5;
        int unsigned generated_count = 0;

        function new(
            mailbox #(fifo_transaction) outbox,
            int unsigned transaction_count
        );
            this.outbox = outbox;
            this.transaction_count = transaction_count;
        endfunction
        
        task run();
            fifo_transaction tr;
            int unsigned i;
            i = 0;

            fifo_ordering();
            //generated_count = generated_count + 6;
            full();
            //generated_count = generated_count + DEPTH;
            write_while_full();
            //generated_count = generated_count + 1;
            write_and_read_while_full();
            //generated_count = generated_count + 3;
            empty();
            //generated_count = generated_count + DEPTH;
            read_while_empty();
            //generated_count = generated_count + 1;
            read_and_write_while_empty();
            //generated_count = generated_count + 3;
            read_and_write();
            //generated_count = generated_count + 6;
            wrap_around();
            //generated_count = generated_count + 6 + DEPTH*2;

            $display("Random.");//Проверка случайным перебором на случай, если есть неучтённый сценарий.
            repeat (transaction_count_for_rand) begin 
                tr = new();
                tr.generate_random();
                tr.id = i;
                //На данном этапе нет необходимости в том, чтобы печатать результат работы генератора, так как он уже проверен и меня интересует работа среды вцелом
                //tr.print("Generator:");
                outbox.put(tr);
                i++;
            end
            generated_count = generated_count + i;
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

    endclass 
endpackage