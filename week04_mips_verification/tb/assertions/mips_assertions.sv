module mips_assertions (
    mips_if.CHECK_MP vif
);
    int unsigned assertion_errors = 0;

    logic [5:0] opcode;
    logic [4:0] rs;
    logic [4:0] rt;
    logic [4:0] rd;
    logic [4:0] shamt;
    logic [5:0] funct;
    logic [15:0] imm;

    assign opcode = vif.instr [31:26];
    assign rs = vif.instr [25:21];
    assign rt = vif.instr [20:16];
    assign rd = vif.instr [15:11];
    assign shamt = vif.instr [10:6];
    assign funct = vif.instr [5:0];
    assign imm = vif.instr [15:0]; 

    property p_reset_states;
        @(posedge vif.clock)
        
        vif.reset
        |->
        (!vif.pc);
    endproperty
    a_reset_states:
        assert property (p_reset_states) 
        else   begin
            $error("Assert: Incorrect states after reset signal.");
            assertion_errors++;
        end

    property p_pc_alignment;
        @(posedge vif.clock)
        disable iff (vif.reset)

        (vif.pc % 4 == 0);
    endproperty
    a_pc_alignment:
        assert property (p_pc_alignment) 
        else   begin
            $error("Assert: pc isn't multiples of four.");
            assertion_errors++;
        end

    property p_zero_reg;
        @(posedge vif.clock)
        disable iff (vif.reset)
        /*
        ((opcode == 6'b000000) & (rd == '0) & (vif.we_reg == 1'b1))
        |->
        (vif.wd_reg == '0);

        (((opcode == 6'b100011) | (opcode == 6'b001000)) & (rt == '0) & (vif.we_reg == 1'b1))
        |->
        (vif.wd_reg == '0);
        */
        ((opcode == 6'b101011) & (rt == '0) & (vif.we_mem == 1'b1))
        |->
        (vif.wd_mem == '0);
    endproperty
    a_zero_reg:
        assert property (p_zero_reg) 
        else   begin
            $error("Assert: zero register isn't zero.");
            assertion_errors++;
        end
    
    property p_register_write_timing;
        @(posedge vif.clock)
        disable iff (vif.reset)

        vif.we_reg 
        |->
        (!$isunknown({vif.wa_reg, vif.wd_reg}) && opcode inside {6'b000000, 6'b100011, 6'b001000} && vif.wa_reg == ((opcode == 6'b000000) ? rd : rt));
    endproperty
    a_register_write_timing:
        assert property (p_register_write_timing) 
        else   begin
            $error("Assert: register don't write in timing.");
            assertion_errors++;
        end

    property p_memory_write;
        @(posedge vif.clock)
        disable iff (vif.reset)

        (vif.we_mem == 1'b1)
        |->
        !$isunknown({vif.address_mem, vif.wd_mem});
    endproperty
    a_memory_write:
        assert property (p_memory_write) 
        else   begin
            $error("Assert: memory adress or data is invalid.");
            assertion_errors++;
        end

    property p_valid_enable_signals;
        @(posedge vif.clock)
        disable iff (vif.reset)

        !$isunknown({vif.we_mem, vif.we_reg});
    endproperty
    a_valid_enable_signals:
        assert property (p_valid_enable_signals) 
        else   begin
            $error("Assert: enable signals invalid.");
            assertion_errors++;
        end
    
   
endmodule