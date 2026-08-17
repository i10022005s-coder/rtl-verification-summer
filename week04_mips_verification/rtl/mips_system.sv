module mips_system #(
    parameter IMEM_FILE = ""
)    (
    input logic clock,
    input logic reset
);
    
    logic [31:0] instr, pc;
    logic [31:0] alu_result, write_data;
    logic        mem_write;
    logic [31:0] read_data;

    mips_core mips_core(
        .clock (clock),
        .reset (reset),

        .instr (instr),
        .pc (pc),

        .alu_result (alu_result),
        .write_data (write_data),
        .mem_write (mem_write),
        .read_data (read_data)
    );
    data_mem data_mem(
        .clock (clock),
        .we (mem_write),
        .addr (alu_result),
        .wd (write_data),
        .rd (read_data)
    );
    instr_mem #(
        .INIT_FILE (IMEM_FILE),
        .DEPTH (64)
    ) instr_mem(
        .addr (pc),
        .instr (instr)
    );

endmodule