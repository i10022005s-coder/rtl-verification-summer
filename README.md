## Day 6 — FSM sequence detector

В этот день был реализован конечный автомат `sequence_detector_1011`, который обнаруживает последовательность битов `1011` во входном потоке.

### Implemented files

- `rtl/sequence_detector_1011.sv`
- `tb/sequence_detector_tb.sv`
- `tb/data/input_bits_seq_det.txt`

### FSM type

Был реализован Mealy-подобный автомат с зарегистрированным выходом `detected`.

Это означает, что логика обнаружения зависит от текущего состояния и входного бита, но сам выход `detected` обновляется только по фронту `clock`.

### Interface

systemverilog
module sequence_detector_1011 (
    input  logic clock,
    input  logic reset,
    input  logic serial_in,
    output logic detected
);
State meaning
State	Meaning
S0	No useful prefix detected
S1	Prefix 1 detected
S2	Prefix 10 detected
S3	Prefix 101 detected
Transition idea

The detector searches for the sequence:

1011

When the FSM is in state S3 and receives serial_in = 1, the sequence 1011 has been detected. The output detected becomes 1 for one clock cycle.

After detection, the FSM goes to S1, because the last 1 can also be the beginning of a new sequence.

Testbench

The testbench is self-checking. It reads input bits from:

tb/data/input_bits_seq_det.txt

For each input bit, the testbench:

Applies the bit to serial_in;
Waits for the next positive clock edge;
Updates the expected 4-bit history;
Checks whether detected matches the expected value.

The expected detection condition is:

expected_detected = (history === 4'b1011);
Simulation

Compile:

iverilog -g2012 -o sim/sequence_detector_tb.out \
    tb/sequence_detector_tb.sv \
    rtl/sequence_detector_1011.sv

Run:

vvp sim/sequence_detector_tb.out

Open waveform:

gtkwave sequence_detector_1011_tb.vcd

Expected output:

TEST PASSED
What this module synthesizes into
state synthesizes into a state register.
nextstate logic synthesizes into combinational transition logic.
detected synthesizes into a flip-flop.
next_detected synthesizes into combinational output logic.

## Day 7 — Synchronous FIFO

В этот день был реализован модуль `sync_fifo` — простой синхронный FIFO на одном тактовом сигнале.

FIFO работает как очередь: данные читаются в том же порядке, в котором были записаны.

### Implemented files

- `rtl/sync_fifo.sv`
- `tb/sync_fifo_tb.sv`

### Interface

module sync_fifo #(
    parameter int WIDTH = 8,
    parameter int DEPTH = 8
) (
    input  logic             clk,
    input  logic             rst_n,
    input  logic             wr_en,
    input  logic             rd_en,
    input  logic [WIDTH-1:0] wdata,
    output logic [WIDTH-1:0] rdata,
    output logic             full,
    output logic             empty
);
Internal structure
mem — memory array for stored data;
wr_ptr — write pointer;
rd_ptr — read pointer;
count — number of stored elements.
Flags
Flag	Meaning
empty	FIFO contains no data
full	FIFO contains DEPTH elements
Behavior
Write is performed when wr_en = 1 and full = 0.
Read is performed when rd_en = 1 and empty = 0.
When write and read happen at the same time, count does not change.
rdata is registered and updates on read.
Simulation
iverilog -g2012 -o sim/sync_fifo_tb.out \
    tb/sync_fifo_tb.sv \
    rtl/sync_fifo.sv

vvp sim/sync_fifo_tb.out
gtkwave sync_fifo_tb.vcd
What this module synthesizes into
mem synthesizes into a small memory/register array;
wr_ptr and rd_ptr synthesize into pointer registers;
count synthesizes into a counter register;
full and empty synthesize into comparator logic;
control logic prevents read from empty FIFO and write to full FIFO.


## Week 01 — SystemVerilog RTL Basics

| Day | Topic | Main files |
|---|---|---|
| Day 1 | Basic combinational logic | mux4, decoder2to4, priority_encoder4, parity4 |
| Day 2 | Combinational coding styles | mux4_assign, mux4_if, mux4_case, comparator4 |
| Day 3 | Arithmetic blocks | half_adder, full_adder, adder4, subtractor4 |
| Day 4 | ALU | alu4 |
| Day 5 | Sequential logic | dff, register_en, shift_register, counter_modN |
| Day 6 | FSM | sequence_detector_1011 |
| Day 7 | Synchronous FIFO | sync_fifo |

## How to run simulations

Run all tests:

bash
make all

Run a specific test:

make alu
make seq
make fsm
make fifo

Clean simulation files:

make clean

## Week 02 — CPU Datapath Basics

### Day 2 — Register File

В этот день был реализован модуль `reg_file` — регистровый файл с двумя портами чтения и одним портом записи.

### Implemented files

- `week02_cpu_datapath/rtl/reg_file.sv`
- `week02_cpu_datapath/tb/reg_file_tb.sv`

### Interface

systemverilog
module reg_file #(
    parameter int DATA_WIDTH = 32,
    parameter int ADDR_WIDTH = 5
) (
    input  logic                  clk,
    input  logic                  rst_n,
    input  logic                  we,
    input  logic [ADDR_WIDTH-1:0] ra1,
    input  logic [ADDR_WIDTH-1:0] ra2,
    input  logic [ADDR_WIDTH-1:0] wa,
    input  logic [DATA_WIDTH-1:0] wd,
    output logic [DATA_WIDTH-1:0] rd1,
    output logic [DATA_WIDTH-1:0] rd2
);
Behavior
Read ports are combinational.
Write port is synchronous.
Register r0 is hardwired to zero.
Write to r0 is ignored.
Two registers can be read at the same time.
Simulation
make regfile
What this module synthesizes into
regs synthesizes into a register array.
Write logic synthesizes into synchronous write enable logic.
Read ports synthesize into multiplexers.
Zero register logic forces register 0 to always read as zero.
### Day 3 — Instruction and Data Memory

Implemented:

- combinational instruction ROM;
- loading memory contents with `$readmemh`;
- data RAM with combinational read;
- synchronous write with write enable;
- conversion of a byte address into a word index.

Files:

- `rtl/instr_mem.sv`
- `rtl/data_mem.sv`
- `tb/memory_tb.sv`
- `tb/data/program.hex`

Run:

bash
make memory
### Day 4 — MIPS Instruction Decoder

Implemented a combinational decoder that extracts:

- opcode;
- rs, rt and rd register addresses;
- shamt;
- funct;
- 16-bit immediate;
- sign-extended 32-bit immediate.

Supported instruction formats:

- R-type;
- I-type.

Run:

bash
make decoder
### Day 5 — MIPS Control Unit

Implemented the control unit for a single-cycle MIPS processor.

The control unit consists of two combinational modules:

- `main_decoder.sv` — decodes the instruction opcode and generates
  datapath control signals;
- `alu_decoder.sv` — selects the required ALU operation using
  `alu_op` and the R-type `funct` field.

Supported instructions:

- R-type: `add`, `sub`, `and`, `or`, `slt`;
- `lw`;
- `sw`;
- `beq`;
- `addi`.

Generated control signals:

- `reg_write`;
- `reg_dst`;
- `alu_src`;
- `mem_write`;
- `mem_to_reg`;
- `branch`;
- `alu_op`;
- `alu_control`.

The self-checking testbench verifies all supported instructions,
an unknown opcode, and an unknown R-type function code.

Run the test:

bash
make control
### Day 6 — MIPS Single-Cycle Datapath

Implemented the datapath of a single-cycle MIPS processor.

New RTL modules:

- `pc_reg.sv` — 32-bit program counter register with asynchronous reset;
- `mux2.sv` — parameterized two-input multiplexer;
- `mips_alu.sv` — processor ALU supporting AND, OR, ADD, SUB and signed SLT;
- `datapath.sv` — integrates the program counter, instruction decoder,
  register file, ALU and datapath multiplexers.

The datapath supports:

- sequential PC update using `PC + 4`;
- forward and backward branch address calculation;
- selection of `rt` or `rd` as the destination register;
- selection of a register value or extended immediate as the second ALU operand;
- selection of the ALU result or memory data for register write-back;
- generation of memory address and write data;
- generation of the ALU `zero` flag.

The self-checking testbench verifies:

- asynchronous PC reset;
- PC register updates and value retention;
- both multiplexer inputs;
- all supported ALU operations;
- signed SLT;
- sequential PC execution;
- forward and backward branches;
- `addi`;
- `lw`;
- `sw`;
- R-type register destination selection;
- disabled register writes;
- protection of register `$0`;
- asserted and deasserted `zero` flag.

Run:

bash
make datapath
### Day 7 — Complete Single-Cycle MIPS System

Completed the integration of a single-cycle MIPS processor.

The top-level system contains:

- `instr_mem.sv` — instruction memory initialized from a hexadecimal file;
- `data_mem.sv` — data memory with asynchronous read and synchronous write;
- `controller.sv` — combines the main decoder and ALU decoder;
- `mips_core.sv` — combines the controller and datapath;
- `mips_system.sv` — connects the processor core to instruction and data memories.

System hierarchy:

mips_system
├── instr_mem
├── data_mem
└── mips_core
    ├── controller
    │   ├── main_decoder
    │   └── alu_decoder
    └── datapath
The processor currently supports:

R-type add, sub, and, or, and slt;
addi;
lw;
sw;
beq.

The integration test loads the following program from
tb/data/program.hex:

addi $1, $0, 5
addi $2, $0, 7
add  $3, $1, $2
sw   $3, 0($0)
lw   $4, 0($0)
beq  $4, $3, label
addi $5, $0, 99
label:
addi $5, $0, 42
sw   $5, 4($0)

The expected program flow is:

PC: 0 → 4 → 8 → 12 → 16 → 20 → 28 → 32

The instruction at address 24 must be skipped by beq.

Expected final data memory contents:

memory[0] = 12
memory[1] = 42

The self-checking testbench verifies:

program loading from a hexadecimal file;
instruction execution without manually supplied control signals;
arithmetic and register write-back;
data memory writes and reads;
the taken beq branch;
the final contents of data memory.

Run the integration test:

make mips

Run the complete regression:

make all

Expected result:

ALL MIPS SYSTEM TESTS PASSED
