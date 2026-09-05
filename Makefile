WEEK1 = week01_sv_basics
WEEK2 = week02_cpu_datapath
WEEK4 = week04_mips_verification

IVERILOG = iverilog
VVP = vvp
FLAGS = -g2012

SIM_DIR = $(WEEK1)/sim
SIM2_DIR = $(WEEK2)/sim

.PHONY: all mips datapath control comb day2 arith alu seq fsm fifo regfile memory decoder clean

all: mips datapath control comb day2 arith alu seq fsm fifo regfile memory decoder

$(SIM_DIR):
	mkdir -p $(SIM_DIR)

comb: $(SIM_DIR)
	$(IVERILOG) $(FLAGS) -o $(SIM_DIR)/comb_blocks_tb.out \
		$(WEEK1)/tb/comb_blocks_tb.sv \
		$(WEEK1)/rtl/mux4.sv \
		$(WEEK1)/rtl/decoder2to4.sv \
		$(WEEK1)/rtl/priority_encoder4.sv \
		$(WEEK1)/rtl/parity4.sv
	cd $(WEEK1) && vvp sim/comb_blocks_tb.out

day2: $(SIM_DIR)
	$(IVERILOG) $(FLAGS) -o $(SIM_DIR)/day2_comb_tb.out \
		$(WEEK1)/tb/day2_comb_tb.sv \
		$(WEEK1)/rtl/mux4_assign.sv \
		$(WEEK1)/rtl/mux4_if.sv \
		$(WEEK1)/rtl/mux4_case.sv \
		$(WEEK1)/rtl/comparator4.sv
	cd $(WEEK1) && vvp sim/day2_comb_tb.out

arith: $(SIM_DIR)
	$(IVERILOG) $(FLAGS) -o $(SIM_DIR)/arith_tb.out \
		$(WEEK1)/tb/arith_tb.sv \
		$(WEEK1)/rtl/half_adder.sv \
		$(WEEK1)/rtl/full_adder.sv \
		$(WEEK1)/rtl/adder4.sv \
		$(WEEK1)/rtl/subtractor4.sv \
		$(WEEK1)/rtl/comparator4_v2.sv
	cd $(WEEK1) && vvp sim/arith_tb.out

alu: $(SIM_DIR)
	$(IVERILOG) $(FLAGS) -o $(SIM_DIR)/alu4_tb.out \
		$(WEEK1)/tb/alu4_tb.sv \
		$(WEEK1)/rtl/alu4.sv
	cd $(WEEK1) && vvp sim/alu4_tb.out

seq: $(SIM_DIR)
	$(IVERILOG) $(FLAGS) -o $(SIM_DIR)/seq_blocks_tb.out \
		$(WEEK1)/tb/seq_blocks_tb.sv \
		$(WEEK1)/rtl/dff.sv \
		$(WEEK1)/rtl/register_en.sv \
		$(WEEK1)/rtl/shift_register.sv \
		$(WEEK1)/rtl/counter_modN.sv
	cd $(WEEK1) && vvp sim/seq_blocks_tb.out

fsm: $(SIM_DIR)
	$(IVERILOG) $(FLAGS) -o $(SIM_DIR)/sequence_detector_tb.out \
		$(WEEK1)/tb/sequence_detector_tb.sv \
		$(WEEK1)/rtl/sequence_detector_1011.sv
	cd $(WEEK1) && vvp sim/sequence_detector_tb.out

fifo: $(SIM_DIR)
	$(IVERILOG) $(FLAGS) -o $(SIM_DIR)/sync_fifo_tb.out \
		$(WEEK1)/tb/sync_fifo_tb.sv \
		$(WEEK1)/rtl/sync_fifo.sv
	cd $(WEEK1) && vvp sim/sync_fifo_tb.out

clean:
	rm -rf $(SIM_DIR)
	rm -f $(WEEK1)/*.vcd
	rm -f $(WEEK2)/sim/*.out
	rm -f $(WEEK2)/sim/*.vcd

regfile:
	mkdir -p $(SIM2_DIR)
	$(IVERILOG) $(FLAGS) -o $(SIM2_DIR)/reg_file_tb.out \
		$(WEEK2)/tb/reg_file_tb.sv \
		$(WEEK2)/rtl/reg_file.sv
	cd $(WEEK2) && vvp sim/reg_file_tb.out
memory:
	mkdir -p $(SIM2_DIR)
	$(IVERILOG) $(FLAGS) -o $(SIM2_DIR)/memory_tb.out \
		$(WEEK2)/tb/memory_tb.sv \
		$(WEEK2)/rtl/instr_mem.sv \
		$(WEEK2)/rtl/data_mem.sv
	cd $(WEEK2) && vvp sim/memory_tb.out
decoder:
	mkdir -p $(SIM2_DIR)
	$(IVERILOG) $(FLAGS) -o $(SIM2_DIR)/instruction_decoder_tb.out \
		$(WEEK2)/tb/instruction_decoder_tb.sv \
		$(WEEK2)/rtl/instruction_decoder.sv
	cd $(WEEK2) && vvp sim/instruction_decoder_tb.out
control:
	mkdir -p $(SIM2_DIR)
	$(IVERILOG) $(FLAGS) -s test \
		-o $(SIM2_DIR)/control_unit_tb.out \
		$(WEEK2)/rtl/main_decoder.sv \
		$(WEEK2)/rtl/alu_decoder.sv \
		$(WEEK2)/tb/control_unit_tb.sv
	cd $(WEEK2) && $(VVP) sim/control_unit_tb.out
datapath:
	mkdir -p $(SIM2_DIR)
	$(IVERILOG) $(FLAGS) -Wall -s test \
		-o $(SIM2_DIR)/datapath_tb.out \
		$(WEEK2)/rtl/pc_reg.sv \
		$(WEEK2)/rtl/mux2.sv \
		$(WEEK2)/rtl/mips_alu.sv \
		$(WEEK2)/rtl/instruction_decoder.sv \
		$(WEEK2)/rtl/reg_file.sv \
		$(WEEK2)/rtl/datapath.sv \
		$(WEEK2)/tb/datapath_tb.sv
	cd $(WEEK2) && $(VVP) sim/datapath_tb.out
mips:
	mkdir -p $(WEEK2)/sim
	cd $(WEEK2) && $(IVERILOG) $(FLAGS) -Wall -s test \
		-o sim/mips_system.out \
		rtl/mux2.sv \
		rtl/pc_reg.sv \
		rtl/reg_file.sv \
		rtl/mips_alu.sv \
		rtl/instruction_decoder.sv \
		rtl/datapath.sv \
		rtl/main_decoder.sv \
		rtl/alu_decoder.sv \
		rtl/controller.sv \
		rtl/mips_core.sv \
		rtl/instr_mem.sv \
		rtl/data_mem.sv \
		rtl/mips_system.sv \
		tb/mips_system_tb.sv
	cd $(WEEK2) && $(VVP) sim/mips_system.out
WEEK3 = week03_sv_verification

.PHONY: fifo_day5 fifo_day4 fifo_day3 fifo_day2 fifo_week3 clean_week3

fifo_week3:
	rm -rf $(WEEK3)/work
	mkdir -p $(WEEK3)/sim
	cd $(WEEK3) && vlib work
	cd $(WEEK3) && vlog -sv \
		tb/transactions/fifo_transaction.sv \
		tb/interfaces/fifo_if.sv \
		rtl/sync_fifo.sv \
		tb/top/fifo_tb.sv
	cd $(WEEK3) && vsim -c work.fifo_tb \
		-do "run -all; quit -f"

fifo_day2:
	rm -rf $(WEEK3)/work
	cd $(WEEK3) && vlib work
	cd $(WEEK3) && vlog -sv \
		tb/transactions/fifo_transaction.sv \
		tb/interfaces/fifo_if.sv \
		tb/components/fifo_generator.sv \
		tb/components/fifo_driver.sv \
		rtl/sync_fifo.sv \
		tb/top/fifo_tb2.sv
	cd $(WEEK3) && vsim -c work.fifo_tb2 \
		-do "run -all; quit -f"
fifo_day3:
	rm -rf $(WEEK3)/work
	cd $(WEEK3) && vlib work
	cd $(WEEK3) && vlog -sv \
		tb/transactions/fifo_transaction.sv \
		tb/interfaces/fifo_if.sv \
		rtl/sync_fifo.sv \
		tb/components/fifo_generator.sv \
		tb/components/fifo_driver.sv \
		tb/components/fifo_monitor.sv \
		tb/components/fifo_scoreboard.sv \
		tb/environment/fifo_environment.sv \
		tb/top/fifo_tb3.sv
	cd $(WEEK3) && vsim -c work.fifo_tb3 \
		-do "run -all; quit -f"
fifo_day4:
	rm -rf $(WEEK3)/work
	cd $(WEEK3) && vlib work
	cd $(WEEK3) && vlog -sv \
		tb/transactions/fifo_transaction.sv \
		tb/interfaces/fifo_if.sv \
		rtl/sync_fifo.sv \
		tb/components/fifo_generator.sv \
		tb/components/fifo_driver.sv \
		tb/components/fifo_monitor.sv \
		tb/components/fifo_scoreboard.sv \
		tb/environment/fifo_environment.sv \
		tb/top/fifo_tb4.sv
	cd $(WEEK3) && vsim -c work.fifo_tb4 \
		-do "run -all; quit -f"
fifo_day5:
	rm -rf $(WEEK3)/work
	cd $(WEEK3) && vlib work
	cd $(WEEK3) && vlog -sv \
		tb/transactions/fifo_transaction.sv \
		tb/interfaces/fifo_if.sv \
		rtl/sync_fifo.sv \
		tb/components/fifo_generator.sv \
		tb/components/fifo_driver.sv \
		tb/components/fifo_monitor.sv \
		tb/components/fifo_scoreboard.sv \
		tb/components/fifo_manual_coverage.sv \
		tb/environment/fifo_environment.sv \
		tb/top/fifo_tb5.sv
	cd $(WEEK3) && vsim -c work.fifo_tb5 \
		-do "run -all; quit -f"
.PHONY: fifo_day6

fifo_day6:
	rm -rf $(WEEK3)/work
	cd $(WEEK3) && vlib work
	cd $(WEEK3) && vlog -sv \
		tb/transactions/fifo_transaction.sv \
		tb/interfaces/fifo_if.sv \
		rtl/sync_fifo.sv \
		tb/components/fifo_generator.sv \
		tb/components/fifo_driver.sv \
		tb/components/fifo_monitor.sv \
		tb/components/fifo_scoreboard.sv \
		tb/components/fifo_manual_coverage.sv \
		tb/environment/fifo_environment.sv \
		tb/assertion/fifo_assertion.sv \
		tb/top/fifo_tb6.sv
	cd $(WEEK3) && vsim -c work.fifo_tb6 \
		-do "run -all; quit -f"

REGRESSION_SEEDS := 10000 10001 10002 10003 10004
SEED ?= 12345

.PHONY: fifo_day7_compile fifo_day7 fifo_regression

fifo_day7_compile:
	rm -rf $(WEEK3)/work
	cd $(WEEK3) && vlib work
	cd $(WEEK3) && vlog -sv \
		tb/transactions/fifo_transaction.sv \
		tb/interfaces/fifo_if.sv \
		rtl/sync_fifo.sv \
		tb/components/fifo_generator.sv \
		tb/components/fifo_driver.sv \
		tb/components/fifo_monitor.sv \
		tb/components/fifo_scoreboard.sv \
		tb/components/fifo_manual_coverage.sv \
		tb/environment/fifo_environment.sv \
		tb/assertion/fifo_assertion.sv \
		tb/top/fifo_tb7.sv

fifo_day7: fifo_day7_compile
	cd $(WEEK3) && vsim -c work.fifo_tb7 +SEED=$(SEED) \
		-do "run -all; quit -f"

fifo_regression: fifo_day7_compile
	@mkdir -p $(WEEK3)/sim/logs
	@passed=0; failed=0; \
	for seed in $(REGRESSION_SEEDS); do \
		printf "Seed %s ... " $$seed; \
		if (cd $(WEEK3) && vsim -c work.fifo_tb7 +SEED=$$seed \
			-do "run -all; quit -f" \
			> sim/logs/seed_$$seed.log 2>&1); then \
			echo "PASS"; \
			passed=$$((passed + 1)); \
		else \
			echo "FAIL"; \
			failed=$$((failed + 1)); \
		fi; \
	done; \
	echo "----------------------------"; \
	echo "Passed: $$passed"; \
	echo "Failed: $$failed"; \
	test $$failed -eq 0

clean_week3:
	rm -rf $(WEEK3)/work
	rm -f $(WEEK3)/sim/*.vcd
	rm -f $(WEEK3)/transcript
	rm -f $(WEEK3)/vsim.wlf


.PHONY: mips_day2

mips_day2:
	rm -rf $(WEEK4)/work
	cd $(WEEK4) && vlib work
	cd $(WEEK4) && vlog -sv -work work \
		tb/transactions/mips_transaction.sv \
		tb/interfaces/mips_if.sv \
		tb/components/mips_monitor.sv \
		rtl/mux2.sv \
		rtl/pc_reg.sv \
		rtl/reg_file.sv \
		rtl/instruction_decoder.sv \
		rtl/mips_alu.sv \
		rtl/main_decoder.sv \
		rtl/alu_decoder.sv \
		rtl/controller.sv \
		rtl/datapath.sv \
		rtl/mips_core.sv \
		rtl/data_mem.sv \
		rtl/instr_mem.sv \
		rtl/mips_system.sv \
		tb/top/mips_day2_tb.sv
	cd $(WEEK4) && vsim -c work.mips_tb \
		-do "run -all; quit -f"

.PHONY: mips_day4

mips_day4:
	rm -rf $(WEEK4)/work
	cd $(WEEK4) && vlib work
	cd $(WEEK4) && vlog -sv -work work \
		tb/transactions/mips_transaction.sv \
		tb/interfaces/mips_if.sv \
		tb/components/mips_monitor.sv \
		tb/components/mips_reference_model.sv \
		tb/components/mips_scoreboard.sv \
		tb/environment/mips_environment.sv \
		rtl/*.sv \
		tb/top/mips_day4_tb.sv

	cd $(WEEK4) && vsim -c work.mips_tb4 -do "run -all; quit -f"

.PHONY: mips_day5

mips_day5:
	rm -rf $(WEEK4)/work
	cd $(WEEK4) && vlib work
	cd $(WEEK4) && vlog -sv -work work \
		tb/transactions/mips_transaction.sv \
		tb/interfaces/mips_if.sv \
		tb/components/mips_monitor.sv \
		tb/components/mips_reference_model.sv \
		tb/components/mips_scoreboard.sv \
		tb/environment/mips_environment_day5.sv \
		rtl/*.sv \
		tb/top/mips_day5_tb.sv

	cd $(WEEK4) && vsim -c work.mips_tb5 -do "run -all; quit -f"

.PHONY: mips_day6

mips_day6:
	rm -rf $(WEEK4)/work
	cd $(WEEK4) && vlib work
	cd $(WEEK4) && vlog -sv -work work \
		tb/transactions/mips_transaction.sv \
		tb/interfaces/mips_if.sv \
		tb/components/mips_monitor.sv \
		tb/components/mips_reference_model.sv \
		tb/components/mips_scoreboard.sv \
		tb/coverage/mips_manual_coverage.sv \
		tb/environment/mips_environment.sv \
		rtl/*.sv \
		tb/top/mips_day6_tb.sv

	cd $(WEEK4) && vsim -c work.mips_tb6 -do "run -all; quit -f"

.PHONY: mips_day7

mips_day7:
	rm -rf $(WEEK4)/work
	cd $(WEEK4) && vlib work
	cd $(WEEK4) && vlog -sv -work work \
		tb/transactions/mips_transaction.sv \
		tb/interfaces/mips_if.sv \
		tb/components/mips_monitor.sv \
		tb/components/mips_reference_model.sv \
		tb/components/mips_scoreboard.sv \
		tb/coverage/mips_manual_coverage.sv \
		tb/environment/mips_environment.sv \
		rtl/*.sv \
		tb/assertions/mips_assertions.sv \
		tb/top/mips_day7_tb.sv

	cd $(WEEK4) && vsim -c work.mips_tb7 -do "run -all; quit -f"

.PHONY: clean_week4

clean_week4:
	rm -rf $(WEEK4)/work
	rm -f $(WEEK4)/transcript
	rm -f $(WEEK4)/vsim.wlf
	rm -f $(WEEK4)/sim/*.vcd

