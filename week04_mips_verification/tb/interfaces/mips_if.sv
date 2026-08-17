interface mips_if (
    input logic clock
);
    
    logic reset;

    logic [31:0] pc;
    logic [31:0] instr;

    logic we_reg;
    logic [4:0] wa_reg;
    logic [31:0] wd_reg;
    logic [31:0] rd_reg;

    logic we_mem;
    logic [31:0] wd_mem;
    logic [31:0] rd_mem;
    logic [31:0] address_mem;

    modport CHECK_MP (
        input clock,
        input reset,

        input pc,
        input instr,

        input we_reg,
        input wa_reg,
        input wd_reg,
        input rd_reg,

        input we_mem,
        input wd_mem,
        input rd_mem,
        input address_mem
    );
endinterface 