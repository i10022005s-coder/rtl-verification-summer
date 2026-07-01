RTL Verification Summer

Учебный проект по Verilog/SystemVerilog, RTL-дизайну и основам верификации.

Week 01 — SystemVerilog RTL Basics

Day 4 — 4-bit ALU

В этот день был реализован модуль `alu4` — простое 4-битное арифметико-логическое устройство.

ALU является комбинационным блоком. На вход поступают два 4-битных операнда `a` и `b`, а также управляющий код операции `op`. На выходе формируется результат `result` и флаги состояния: `zero`, `carry`, `overflow`.

Interface

module alu4 (
    input  logic [3:0] a,
    input  logic [3:0] b,
    input  logic [3:0] op,
    output logic [3:0] result,
    output logic       zero,
    output logic       carry,
    output logic       overflow
);


| op   | Operation | Description                  |
| ---- | --------- | ---------------------------- |
| 0000 | ADD       | `a + b`                      |
| 0001 | SUB       | `a - b`                      |
| 0010 | AND       | `a & b`                      |
| 0011 | OR        | `a \| b`                     |
| 0100 | XOR       | `a ^ b`                      |
| 0101 | SLT       | signed comparison: `a < b`   |
| 0110 | SLTU      | unsigned comparison: `a < b` |
| 0111 | SLL       | logical shift left           |
| 1000 | SRL       | logical shift right          |
| 1001 | SRA       | arithmetic shift right       |


| Flag       | Meaning                                      |
| ---------- | -------------------------------------------- |
| `zero`     | Set to `1` when `result == 0`                |
| `carry`    | Carry flag for ADD; borrow indicator for SUB |
| `overflow` | Signed overflow flag for ADD/SUB             |

* `ADD` and `SUB` use the same binary arithmetic for both signed and unsigned values.
* For unsigned arithmetic, the `carry` flag is important.
* For signed arithmetic, the `overflow` flag is important.
* `SLT` and `SLTU` are separate operations because signed and unsigned comparisons produce different results for the same bit patterns.
* `SRL` and `SRA` are separate operations because arithmetic right shift preserves the sign bit.

Compile:

```bash
iverilog -g2012 -o sim/alu4_tb.out tb/alu4_tb.sv rtl/alu4.sv
```

Run:

```bash
vvp sim/alu4_tb.out
```

Open waveform:

```bash
gtkwave alu4_tb.vcd
```

Expected result:

```text
TEST PASSED
```

What this module synthesizes into

* `case(op)` becomes selection logic / multiplexer.
* `ADD` and `SUB` use adder/subtractor logic.
* `AND`, `OR`, `XOR` synthesize into basic logic gates.
* `SLT` and `SLTU` synthesize into comparator logic.
* `zero` can be implemented as NOR of all result bits.
* `carry` and `overflow` are additional flag-generation logic.

Day 5 Последовательностные схемы

rtl/dff.sv - синтезирует D-триггер со сбросом reset
rtl/register_en.sv - синтезирует 4-bit регистр со сбросом reset и с сигналом разрешения unable 
rtl/shift_register.sv - синтезирует 4-bit регистр сдвига со сбросом reset и с сигналом разрешения unable
rtl/counter_modN.sv - синтезирует счётчик по модулю, задаваемому параметром N (по-умолчанию 10), со сбросом reset и сигналом запрета счёта unable
tb/seq_blocks.sv - тестбенч, проверяющий модули, указанные выше
 
