transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+C:/Users/Eric/Desktop/UIUC/SP\ 2021/ECE\ 411/Core-i9000/hdl/cache {C:/Users/Eric/Desktop/UIUC/SP 2021/ECE 411/Core-i9000/hdl/cache/arbiter.sv}
vlog -sv -work work +incdir+C:/Users/Eric/Desktop/UIUC/SP\ 2021/ECE\ 411/Core-i9000/hdl/cache {C:/Users/Eric/Desktop/UIUC/SP 2021/ECE 411/Core-i9000/hdl/cache/line_adapter.sv}
vlog -sv -work work +incdir+C:/Users/Eric/Desktop/UIUC/SP\ 2021/ECE\ 411/Core-i9000/hdl/cache {C:/Users/Eric/Desktop/UIUC/SP 2021/ECE 411/Core-i9000/hdl/cache/data_array.sv}
vlog -sv -work work +incdir+C:/Users/Eric/Desktop/UIUC/SP\ 2021/ECE\ 411/Core-i9000/hdl/cache {C:/Users/Eric/Desktop/UIUC/SP 2021/ECE 411/Core-i9000/hdl/cache/cacheline_adaptor.sv}
vlog -sv -work work +incdir+C:/Users/Eric/Desktop/UIUC/SP\ 2021/ECE\ 411/Core-i9000/hdl/cache {C:/Users/Eric/Desktop/UIUC/SP 2021/ECE 411/Core-i9000/hdl/cache/cache_datapath.sv}
vlog -sv -work work +incdir+C:/Users/Eric/Desktop/UIUC/SP\ 2021/ECE\ 411/Core-i9000/hdl/cache {C:/Users/Eric/Desktop/UIUC/SP 2021/ECE 411/Core-i9000/hdl/cache/cache_control.sv}
vlog -sv -work work +incdir+C:/Users/Eric/Desktop/UIUC/SP\ 2021/ECE\ 411/Core-i9000/hdl/cache {C:/Users/Eric/Desktop/UIUC/SP 2021/ECE 411/Core-i9000/hdl/cache/array.sv}
vlog -sv -work work +incdir+C:/Users/Eric/Desktop/UIUC/SP\ 2021/ECE\ 411/Core-i9000/hdl/types {C:/Users/Eric/Desktop/UIUC/SP 2021/ECE 411/Core-i9000/hdl/types/rv32i_mux_types.sv}
vlog -sv -work work +incdir+C:/Users/Eric/Desktop/UIUC/SP\ 2021/ECE\ 411/Core-i9000/hdl/cpu {C:/Users/Eric/Desktop/UIUC/SP 2021/ECE 411/Core-i9000/hdl/cpu/pc_reg.sv}
vlog -sv -work work +incdir+C:/Users/Eric/Desktop/UIUC/SP\ 2021/ECE\ 411/Core-i9000/hdl/cpu {C:/Users/Eric/Desktop/UIUC/SP 2021/ECE 411/Core-i9000/hdl/cpu/fetcher.sv}
vlog -sv -work work +incdir+C:/Users/Eric/Desktop/UIUC/SP\ 2021/ECE\ 411/Core-i9000/hdl/cache {C:/Users/Eric/Desktop/UIUC/SP 2021/ECE 411/Core-i9000/hdl/cache/cache.sv}
vlog -sv -work work +incdir+C:/Users/Eric/Desktop/UIUC/SP\ 2021/ECE\ 411/Core-i9000/hdl/types {C:/Users/Eric/Desktop/UIUC/SP 2021/ECE 411/Core-i9000/hdl/types/rv32i_types.sv}
vlog -sv -work work +incdir+C:/Users/Eric/Desktop/UIUC/SP\ 2021/ECE\ 411/Core-i9000/hdl/cpu {C:/Users/Eric/Desktop/UIUC/SP 2021/ECE 411/Core-i9000/hdl/cpu/branch_predictor.sv}
vlog -sv -work work +incdir+C:/Users/Eric/Desktop/UIUC/SP\ 2021/ECE\ 411/Core-i9000/hdl/cpu {C:/Users/Eric/Desktop/UIUC/SP 2021/ECE 411/Core-i9000/hdl/cpu/cmp.sv}
vlog -sv -work work +incdir+C:/Users/Eric/Desktop/UIUC/SP\ 2021/ECE\ 411/Core-i9000/hdl/cpu {C:/Users/Eric/Desktop/UIUC/SP 2021/ECE 411/Core-i9000/hdl/cpu/load_store_q.sv}
vlog -sv -work work +incdir+C:/Users/Eric/Desktop/UIUC/SP\ 2021/ECE\ 411/Core-i9000/hdl/cpu {C:/Users/Eric/Desktop/UIUC/SP 2021/ECE 411/Core-i9000/hdl/cpu/reservation_station.sv}
vlog -sv -work work +incdir+C:/Users/Eric/Desktop/UIUC/SP\ 2021/ECE\ 411/Core-i9000/hdl/cpu {C:/Users/Eric/Desktop/UIUC/SP 2021/ECE 411/Core-i9000/hdl/cpu/alu.sv}
vlog -sv -work work +incdir+C:/Users/Eric/Desktop/UIUC/SP\ 2021/ECE\ 411/Core-i9000/hdl/cpu {C:/Users/Eric/Desktop/UIUC/SP 2021/ECE 411/Core-i9000/hdl/cpu/reorder_buffer.sv}
vlog -sv -work work +incdir+C:/Users/Eric/Desktop/UIUC/SP\ 2021/ECE\ 411/Core-i9000/hdl/cpu {C:/Users/Eric/Desktop/UIUC/SP 2021/ECE 411/Core-i9000/hdl/cpu/regfile.sv}
vlog -sv -work work +incdir+C:/Users/Eric/Desktop/UIUC/SP\ 2021/ECE\ 411/Core-i9000/hdl/cpu {C:/Users/Eric/Desktop/UIUC/SP 2021/ECE 411/Core-i9000/hdl/cpu/decoder.sv}
vlog -sv -work work +incdir+C:/Users/Eric/Desktop/UIUC/SP\ 2021/ECE\ 411/Core-i9000/hdl/cpu {C:/Users/Eric/Desktop/UIUC/SP 2021/ECE 411/Core-i9000/hdl/cpu/circular_q.sv}
vlog -sv -work work +incdir+C:/Users/Eric/Desktop/UIUC/SP\ 2021/ECE\ 411/Core-i9000/hdl/cpu {C:/Users/Eric/Desktop/UIUC/SP 2021/ECE 411/Core-i9000/hdl/cpu/acu.sv}
vlog -sv -work work +incdir+C:/Users/Eric/Desktop/UIUC/SP\ 2021/ECE\ 411/Core-i9000/hdl/cpu {C:/Users/Eric/Desktop/UIUC/SP 2021/ECE 411/Core-i9000/hdl/cpu/cpu.sv}
vlog -sv -work work +incdir+C:/Users/Eric/Desktop/UIUC/SP\ 2021/ECE\ 411/Core-i9000/hdl {C:/Users/Eric/Desktop/UIUC/SP 2021/ECE 411/Core-i9000/hdl/mp4.sv}

vlog -sv -work work +incdir+C:/Users/Eric/Desktop/UIUC/SP\ 2021/ECE\ 411/Core-i9000/hvl {C:/Users/Eric/Desktop/UIUC/SP 2021/ECE 411/Core-i9000/hvl/cache_monitor_itf.sv}
vlog -sv -work work +incdir+C:/Users/Eric/Desktop/UIUC/SP\ 2021/ECE\ 411/Core-i9000/hvl {C:/Users/Eric/Desktop/UIUC/SP 2021/ECE 411/Core-i9000/hvl/param_memory.sv}
vlog -vlog01compat -work work +incdir+C:/Users/Eric/Desktop/UIUC/SP\ 2021/ECE\ 411/Core-i9000/hvl {C:/Users/Eric/Desktop/UIUC/SP 2021/ECE 411/Core-i9000/hvl/rvfimon.v}
vlog -sv -work work +incdir+C:/Users/Eric/Desktop/UIUC/SP\ 2021/ECE\ 411/Core-i9000/hvl {C:/Users/Eric/Desktop/UIUC/SP 2021/ECE 411/Core-i9000/hvl/shadow_memory.sv}
vlog -sv -work work +incdir+C:/Users/Eric/Desktop/UIUC/SP\ 2021/ECE\ 411/Core-i9000/hvl {C:/Users/Eric/Desktop/UIUC/SP 2021/ECE 411/Core-i9000/hvl/source_tb.sv}
vlog -sv -work work +incdir+C:/Users/Eric/Desktop/UIUC/SP\ 2021/ECE\ 411/Core-i9000/hvl {C:/Users/Eric/Desktop/UIUC/SP 2021/ECE 411/Core-i9000/hvl/tb_itf.sv}
vlog -sv -work work +incdir+C:/Users/Eric/Desktop/UIUC/SP\ 2021/ECE\ 411/Core-i9000/hvl {C:/Users/Eric/Desktop/UIUC/SP 2021/ECE 411/Core-i9000/hvl/top.sv}
vlog -sv -work work +incdir+C:/Users/Eric/Desktop/UIUC/SP\ 2021/ECE\ 411/Core-i9000/hvl {C:/Users/Eric/Desktop/UIUC/SP 2021/ECE 411/Core-i9000/hvl/software_model.sv}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L arriaii_hssi_ver -L arriaii_pcie_hip_ver -L arriaii_ver -L rtl_work -L work -voptargs="+acc"  mp4_tb

do wave.do
view structure
view signals
run -all
