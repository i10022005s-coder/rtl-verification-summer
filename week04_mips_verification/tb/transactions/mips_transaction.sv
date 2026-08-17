package mips_transaction_pkg;

    class mips_transaction; 

        logic [31:0] pc_before;
        logic [31:0] pc_after;
        logic [31:0] instr;

        logic [5:0] opcode;
        logic [4:0] rs;
        logic [4:0] rt;
        logic [4:0] rd;
        logic [4:0] shamt;
        logic [5:0] funct;
        logic [15:0] imm;

        logic we_reg;
        logic [4:0] wa_reg;
        logic [31:0] wd_reg;
        logic [31:0] rd_reg;

        logic we_mem;
        logic [31:0] wd_mem;
        logic [31:0] rd_mem;
        logic [31:0] address_mem;

        function new();
            pc_before = '0;
            pc_after = '0;
            instr = '0;
            opcode = '0;
            rs = '0;
            rt = '0;
            rd = '0;
            shamt = '0;
            funct = '0;
            imm = '0;
            we_reg = 1'b0;
            wa_reg = '0;
            wd_reg = '0;
            rd_reg = '0;
            we_mem = 1'b0;
            wd_mem = '0;
            rd_mem = '0;
            address_mem = '0;
        endfunction

        task decode();
            opcode = instr [31:26];
            rs = instr [25:21];
            rt = instr [20:16];
            rd = instr [15:11];
            shamt = instr [10:6];
            funct = instr [5:0];
            imm = instr [15:0]; 
        endtask

        
    endclass 
endpackage