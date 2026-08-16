module fifo_assertions (
    fifo_if.CHECK_MP vif
);
    int unsigned assertion_errors = 0;

    property p_reset_states;
        @(posedge vif.clock)
        
        vif.reset
        |=>
        (vif.empty && !vif.full && !vif.valid);
    endproperty
    a_reset_states:
        assert property (p_reset_states) 
        else   begin
            $error("Assert: Incorrect states after reset signal.");
            assertion_errors++;
        end

    property p_full_empty;
        @(posedge vif.clock)
        disable iff (vif.reset)

        !(vif.empty && vif.full);
    endproperty
    a_full_empty:
        assert property (p_full_empty) 
        else   begin
            $error("Assert: full and empty is active in one time.");
            assertion_errors++;
        end
    
    property p_control_signal_known;
        @(posedge vif.clock)
        disable iff (vif.reset)

        !$isunknown({vif.full, vif.empty, vif.valid});
    endproperty
    a_control_signal_known:
        assert property (p_control_signal_known) 
        else   begin
            $error("Assert: control signals is unknown.");
            assertion_errors++;
        end
    
    property p_read_empty;
        @(posedge vif.clock)
        disable iff (vif.reset)

        (vif.empty && vif.read_en && !vif.write_en)
        |=>
        !vif.valid;
    endproperty
    a_read_empty:
        assert property (p_read_empty) 
        else   begin
            $error("Assert: valid is active after read from empty FIFO.");
            assertion_errors++;
        end
    
    property p_sucessfull_read_valid;
        @(posedge vif.clock)
        disable iff (vif.reset)

        (!vif.empty && vif.read_en)
        |=>
        vif.valid;
    endproperty
    a_sucessfull_read_valid_empty:
        assert property (p_sucessfull_read_valid) 
        else   begin
            $error("Assert: valid is unactive after read from not empty FIFO.");
            assertion_errors++;
        end
    
    property p_not_empty_after_write;
        @(posedge vif.clock)
        disable iff (vif.reset)

        (vif.empty && !vif.read_en && vif.write_en)
        |=>
        !vif.empty;
    endproperty
    a_not_empty_after_write:
        assert property (p_not_empty_after_write) 
        else   begin
            $error("Assert: FIFO empty after write");
            assertion_errors++;
        end
    
    property p_bypass_empty;
        @(posedge vif.clock)
        disable iff (vif.reset)

        (vif.empty && vif.read_en && vif.write_en)
        |=>
        (vif.empty && vif.valid && vif.read_data == $past(vif.write_data));
    endproperty
    a_bypass_empty:
        assert property (p_bypass_empty) 
        else   begin
            $error("Assert: incorrect bypass on empty FIFO");
            assertion_errors++;
        end

    property p_write_full;
        @(posedge vif.clock)
        disable iff (vif.reset)

        (vif.full && !vif.read_en && vif.write_en)
        |=>
        vif.full;
    endproperty
    a_write_full:
        assert property (p_write_full) 
        else   begin
            $error("Assert: incorrect write in full FIFO");
            assertion_errors++;
        end

    property p_rw_full;
        @(posedge vif.clock)
        disable iff (vif.reset)

        (vif.full && vif.read_en && vif.write_en)
        |=>
        (vif.full && vif.valid);
    endproperty
    a_rw_full:
        assert property (p_rw_full) 
        else   begin
            $error("Assert: incorrect rw in full FIFO");
            assertion_errors++;
        end
endmodule