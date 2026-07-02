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

