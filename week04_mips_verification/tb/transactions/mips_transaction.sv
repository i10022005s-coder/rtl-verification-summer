package mips_transaction_pkg;

    class mips_transaction; 
        
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
        //logic [31:0] rd_reg;

        logic we_mem;
        logic [31:0] wd_mem;
        logic [31:0] rd_mem;
        logic [31:0] address_mem;

        mips_op operation;
        int unsigned id;

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
            //rd_reg = '0;
            we_mem = 1'b0;
            wd_mem = '0;
            rd_mem = '0;
            address_mem = '0;
            operation = OP_UNKNOWN;
            id = 0;
        endfunction

        task decode();
            opcode = instr [31:26];
            rs = instr [25:21];
            rt = instr [20:16];
            rd = instr [15:11];
            shamt = instr [10:6];
            funct = instr [5:0];
            imm = instr [15:0]; 
            
            case (opcode)
                6'b000000: begin
                    case (funct)
                        6'b100000: operation = OP_ADD;
                        6'b100010: operation = OP_SUB;
                        6'b100100: operation = OP_AND;
                        6'b100101: operation = OP_OR;
                        6'b101010: operation = OP_SLT;
                        default: operation = OP_UNKNOWN;
                    endcase
                end
                6'b001000: operation = OP_ADDI;
                6'b100011: operation = OP_LW;
                6'b101011: operation = OP_SW;
                6'b000100: operation = OP_BEQ;
                default: operation = OP_UNKNOWN;
            endcase
        endtask

        task print();
            $display("");
            $display("=================================================================");
            $display("ID: %d", id);
            $display("PC: 0x%8h -> 0x%8h", pc_before, pc_after);
            $display("Instr: 0x%8h", instr);
            $display("opcode = 0x%h, rs = 0x%h,  rt = 0x%h,  rd = 0x%h,  shamt = 0x%h,  funct = 0x%h,  imm = 0x%8h,", opcode, rs, rt, rd, shamt, funct, imm);
            $display("Operation: %s", operation.name());
            $display("REG: we = 0x%b, wa = 0x%8h, wd = 0x%8h", we_reg, wa_reg, wd_reg);
            $display("MEM: we = 0x%b, adress = 0x%8h, wd = 0x%8h, rd = 0x%8h", we_mem, address_mem, wd_mem, rd_mem);
            $display("=================================================================");
        endtask 

        
    endclass 
endpackage