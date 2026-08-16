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

## Week 3 — SystemVerilog Verification

### Day 1 — Interface and Transaction

Started building a class-based verification environment for a
synchronous FIFO.

Implemented:

- `fifo_if.sv` — groups FIFO signals into a SystemVerilog interface;
- `fifo_transaction.sv` — represents a FIFO operation as a class object;
- `fifo_tb.sv` — creates and randomizes transaction objects and manually
  transfers their fields to the interface;
- a self-checking write/read test for the FIFO.

Current verification flow:

fifo_transaction
        ↓
manual transaction-to-signal conversion
        ↓
fifo_if
        ↓
sync_fifo

The testbench verifies:

reset state;
object creation using new();
randomization using randomize();
writing 8'hA5;
reading 8'hA5;
empty, full, and valid behavior;
simulation timeout and automatic PASS/FAIL reporting.

Run:

make fifo_week3

Expected result:

ALL FIFO TESTS Passed
Errors: 0, Warnings: 0
### Week 3 — Day 2: Generator, Mailbox and Driver

Implemented the next stage of the class-based FIFO verification environment.

Added:

- `fifo_generator.sv` — creates randomized FIFO transactions;
- `fifo_driver.sv` — receives transactions and drives the FIFO interface;
- typed `mailbox #(fifo_transaction)` for communication between generator and driver;
- `virtual fifo_if` for access to DUT signals from the driver;
- parallel execution of generator and driver using `fork...join`;
- automatic checks of generated and driven transaction counts.

Current verification flow:

text
fifo_generator
      ↓
fifo_transaction
      ↓
mailbox
      ↓
fifo_driver
      ↓
virtual fifo_if
      ↓
sync_fifo

The generator creates 16 transactions using $urandom_range.
The mailbox is bounded to 8 entries, so the generator blocks when the mailbox
is full until the driver consumes transactions.

The driver applies transaction fields to the FIFO interface on the falling
edge of the clock and the FIFO processes them on the following rising edge.

The testbench checks:

correct FIFO reset state;
generator-to-driver transaction transfer;
number of generated transactions;
number of driven transactions;
simulation timeout.

Run:

make fifo_day2

Expected result:

ALL FIFO TESTS Passed
Errors: 0, Warnings: 0

### Week 3 — Day 3: Monitor, Scoreboard and Environment

Extended the class-based FIFO verification environment.

Implemented:

- `fifo_monitor.sv` — passively observes FIFO interface activity;
- monitor-to-scoreboard mailbox;
- `fifo_scoreboard.sv` — maintains a reference FIFO model using a
  SystemVerilog queue and automatically compares DUT behavior;
- `fifo_environment.sv` — creates, connects and runs verification
  components;
- `fifo_tb3.sv` — top-level testbench using the environment.

Current verification architecture:

Generator
    |
    v
 gen2drv
    |
    v
 Driver -----> fifo_if -----> FIFO
                  |
                  v
               Monitor
                  |
                  v
               mon2scb
                  |
                  v
              Scoreboard

The monitor observes:

write/read requests;
write data;
read data;
empty;
full;
valid.

The scoreboard maintains an independent reference queue and checks:

FIFO write behavior;
FIFO read ordering;
simultaneous read/write;
empty FIFO bypass behavior;
read data;
valid;
empty;
full.

The scoreboard does not inspect the internal FIFO memory, pointers or count.
It predicts expected behavior independently from the DUT.

The environment checks that all requested transactions were:

generated;
driven;
observed;
checked by the scoreboard.

Run:

make fifo_day3

Expected result:

ALL FIFO TESTS Passed

### Week 3 — Day 4: Directed Corner-Case Verification
Extended the FIFO verification environment with directed corner-case
stimulus while keeping the existing driver, monitor, scoreboard and
environment architecture.

The generator now executes deterministic scenarios before random stress
testing.

Directed scenarios:

- FIFO ordering;
- fill FIFO to `full`;
- write while `full`;
- simultaneous read/write while `full`;
- drain FIFO to `empty`;
- read while `empty`;
- simultaneous read/write while `empty`;
- simultaneous read/write in normal operation;
- pointer wrap-around.

After the directed phase, additional random transactions are generated
using `$urandom_range`.

Verification flow remains:

Generator
    |
    v
Driver
    |
    v
FIFO
    |
    v
Monitor
    |
    v
Scoreboard / Reference Model

The scoreboard uses an independent SystemVerilog queue and does not
inspect internal DUT pointers, counters or memory.

For every observed transaction it checks:

- read data;
- `valid`;
- `empty`;
- `full`.

Current test configuration:

- DATA_WIDTH = 8
- DEPTH = 8
- directed corner-case tests
- random stress phase

Run:

bash
make fifo_day4

Expected result:

Tests complete: checks = 98, errors = 0.
ALL FIFO TESTS Passed
Errors: 0, Warnings: 0

### Week 3 — Day 5: Weighted Random and Stress Verification

Extended the FIFO verification environment with controlled random stimulus and long stress testing.

Implemented:

- weighted random transaction generation using `$urandom_range`;
- balanced traffic profile;
- write-heavy traffic profile;
- read-heavy traffic profile;
- 10,000-transaction stress test;
- operation statistics for WRITE, READ, READ+WRITE and IDLE;
- reproducible random seed support;
- reduced console output for long-running tests;
- functional coverage of FIFO operations and states.

Random traffic profiles:

Balanced:
WRITE       25%
READ        25%
READ+WRITE  25%
IDLE        25%

Write-heavy:
WRITE       60%
READ        15%
READ+WRITE  20%
IDLE         5%

Read-heavy:
WRITE       15%
READ        60%
READ+WRITE  20%
IDLE         5%
```

Verification flow:

Directed corner cases
        |
        v
Weighted random profiles
        |
        v
10,000 transaction stress test
        |
        v
Driver -> FIFO -> Monitor -> Scoreboard
                        |
                        +-> Functional coverage
```

The scoreboard continues to use an independent reference queue and checks:

- FIFO ordering;
- read data;
- `valid`;
- `empty`;
- `full`;
- simultaneous read/write behavior.

The coverage collector samples:

- IDLE;
- WRITE;
- READ;
- READ+WRITE;
- NORMAL state;
- EMPTY state;
- FULL state;
- `valid`;
- operation/state combinations.

Run:

```bash
make fifo_day5
```

The test prints:

- selected random seed;
- operation statistics;
- total transaction count;
- functional coverage;
- scoreboard result.

A failing random test can be reproduced by running the same seed again.
### Week 3 — Day 6: SystemVerilog Assertions

Added a SystemVerilog Assertions layer to the existing self-checking FIFO verification environment.

The assertion checker is implemented as a separate module and accesses the FIFO interface through a read-only `CHECK_MP` modport.

Current verification architecture:

Generator
    |
    v
Driver ---> FIFO ---> Monitor ---> Scoreboard / Reference Model
              |
              +------> SVA Checker


Implemented properties check:

- reset state: `empty=1`, `full=0`, `valid=0`;
- `full` and `empty` are never asserted simultaneously;
- FIFO status signals do not contain `X/Z`;
- reading an empty FIFO does not assert `valid`;
- a successful read asserts `valid`;
- writing to an empty FIFO makes it non-empty;
- simultaneous read/write on an empty FIFO performs the expected bypass;
- write-only operation while `full` does not change the full state;
- simultaneous read/write while `full` preserves the full state and produces valid read data.

The assertions use:

- `property`;
- `assert property`;
- `@(posedge clock)`;
- `disable iff`;
- non-overlapped implication `|=>`;
- `$past`;
- `$isunknown`.

Assertions complement the scoreboard rather than replace it:

Scoreboard:
checks data and behavior against an independent reference model.

Assertions:
check temporal rules and invariants of the FIFO interface.


Run:

make fifo_day6


The test passes only if the environment, scoreboard and SVA checker report no errors.

A mutation test was also used to confirm that intentionally incorrect DUT behavior is detected by the assertion checker.

### Week 3 — Day 7: Coverage Closure and Regression

Completed the FIFO verification environment by adding pre-state functional coverage and multi-seed regression testing.

The monitor now records both the requested operation and the FIFO state before that operation:

pre_empty
pre_full
write_en
read_en

This allows functional coverage to measure the meaningful cross:

operation × pre-operation FIFO state

The coverage model contains four operation classes:

- IDLE
- READ
- WRITE
- READ+WRITE

and three FIFO states:

- EMPTY
- NORMAL
- FULL

This produces 12 reachable operation/state cross bins.

Current verification architecture:

                    Generator
                        |
                        v
                     Driver
                        |
                        v
                       FIFO
                        |
             +----------+----------+
             |                     |
          Monitor               Assertions
             |
        +----+----+
        |         |
        v         v
   Scoreboard   Coverage
        |
  Reference model

The complete environment now provides:

- directed corner-case stimulus;
- weighted random stimulus;
- long stress tests;
- reproducible random seeds;
- transaction-level driver and monitor;
- independent FIFO reference model;
- automatic scoreboard checking;
- SystemVerilog Assertions;
- functional coverage;
- operation/state cross coverage;
- coverage closure;
- multi-seed regression.

A single test can be run with:

A specific random sequence can be reproduced with:

make fifo_day7 SEED=10002

The complete regression can be started with:

make fifo_regression

Regression compiles the design once and then runs several independent simulation processes using different seeds. Each seed has a separate log file.

A regression is considered successful only when all runs pass the scoreboard, assertion and environment checks.

This completes Week 3: class-based SystemVerilog FIFO verification environment.
