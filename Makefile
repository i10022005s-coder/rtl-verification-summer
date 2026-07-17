WEEK1 = week01_sv_basics
WEEK2 = week02_cpu_datapath

IVERILOG = iverilog
VVP = vvp
FLAGS = -g2012

SIM_DIR = $(WEEK1)/sim
SIM2_DIR = $(WEEK2)/sim

.PHONY: all control comb day2 arith alu seq fsm fifo regfile memory decoder clean

all: control comb day2 arith alu seq fsm fifo regfile memory decoder

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
