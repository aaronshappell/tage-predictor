ifneq ($(words $(CURDIR)),1)
	$(error Unsupported: GNU Make cannot build in directories containing spaces, build elsewhere: '$(CURDIR)')
endif

ifeq ($(VERILATOR_ROOT),)
VERILATOR = verilator
else
export VERILATOR_ROOT
VERILATOR = $(VERILATOR_ROOT)/bin/verilator
endif

default:
	@echo "--VERILATE -----------------"
	$(VERILATOR) --cc --exe -Isrc/include src/v/top.sv tb/top.cpp
	@echo "--BUILD --------------------"
	make -j -C obj_dir -f Vtop.mk Vtop
	@echo "-- RUN ---------------------"
	obj_dir/Vtop
	@echo "-- DONE --------------------"

%:
	@echo "--VERILATE -----------------"
	$(VERILATOR) --cc --exe -Isrc/include src/v/$@.sv tb/$@.cpp
	@echo "--BUILD --------------------"
	make -j -C obj_dir -f V$@.mk V$@
	@echo "-- RUN ---------------------"
	obj_dir/V$@
	@echo "-- DONE --------------------"

clean:
	-rm -rf obj_dir *.log *.dmp *.vpd core