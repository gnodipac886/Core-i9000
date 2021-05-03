transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+C:/Users/Eric/Desktop/UIUC/SP\ 2021/ECE\ 411/Core-i9000/hdl/cache {C:/Users/Eric/Desktop/UIUC/SP 2021/ECE 411/Core-i9000/hdl/cache/line_adapter.sv}
vlog -sv -work work +incdir+C:/Users/Eric/Desktop/UIUC/SP\ 2021/ECE\ 411/Core-i9000/hdl/cache {C:/Users/Eric/Desktop/UIUC/SP 2021/ECE 411/Core-i9000/hdl/cache/data_array.sv}
vlog -sv -work work +incdir+C:/Users/Eric/Desktop/UIUC/SP\ 2021/ECE\ 411/Core-i9000/hdl/cache {C:/Users/Eric/Desktop/UIUC/SP 2021/ECE 411/Core-i9000/hdl/cache/cache_datapath.sv}
vlog -sv -work work +incdir+C:/Users/Eric/Desktop/UIUC/SP\ 2021/ECE\ 411/Core-i9000/hdl/cache {C:/Users/Eric/Desktop/UIUC/SP 2021/ECE 411/Core-i9000/hdl/cache/cache_control.sv}
vlog -sv -work work +incdir+C:/Users/Eric/Desktop/UIUC/SP\ 2021/ECE\ 411/Core-i9000/hdl/cache {C:/Users/Eric/Desktop/UIUC/SP 2021/ECE 411/Core-i9000/hdl/cache/array.sv}
vlog -sv -work work +incdir+C:/Users/Eric/Desktop/UIUC/SP\ 2021/ECE\ 411/Core-i9000/hdl/cache {C:/Users/Eric/Desktop/UIUC/SP 2021/ECE 411/Core-i9000/hdl/cache/cache.sv}

vlog -sv -work work +incdir+C:/Users/Eric/Desktop/UIUC/SP\ 2021/ECE\ 411/Core-i9000/hvl {C:/Users/Eric/Desktop/UIUC/SP 2021/ECE 411/Core-i9000/hvl/cache_monitor_itf.sv}
vlog -sv -work work +incdir+C:/Users/Eric/Desktop/UIUC/SP\ 2021/ECE\ 411/Core-i9000/hvl {C:/Users/Eric/Desktop/UIUC/SP 2021/ECE 411/Core-i9000/hvl/param_memory.sv}
vlog -vlog01compat -work work +incdir+C:/Users/Eric/Desktop/UIUC/SP\ 2021/ECE\ 411/Core-i9000/hvl {C:/Users/Eric/Desktop/UIUC/SP 2021/ECE 411/Core-i9000/hvl/rvfimon.v}
vlog -sv -work work +incdir+C:/Users/Eric/Desktop/UIUC/SP\ 2021/ECE\ 411/Core-i9000/hvl {C:/Users/Eric/Desktop/UIUC/SP 2021/ECE 411/Core-i9000/hvl/shadow_memory.sv}
vlog -sv -work work +incdir+C:/Users/Eric/Desktop/UIUC/SP\ 2021/ECE\ 411/Core-i9000/hvl {C:/Users/Eric/Desktop/UIUC/SP 2021/ECE 411/Core-i9000/hvl/source_tb.sv}
vlog -sv -work work +incdir+C:/Users/Eric/Desktop/UIUC/SP\ 2021/ECE\ 411/Core-i9000/hvl {C:/Users/Eric/Desktop/UIUC/SP 2021/ECE 411/Core-i9000/hvl/tb_itf.sv}
vlog -sv -work work +incdir+C:/Users/Eric/Desktop/UIUC/SP\ 2021/ECE\ 411/Core-i9000/hvl {C:/Users/Eric/Desktop/UIUC/SP 2021/ECE 411/Core-i9000/hvl/top.sv}
vlog -sv -work work +incdir+C:/Users/Eric/Desktop/UIUC/SP\ 2021/ECE\ 411/Core-i9000/hvl {C:/Users/Eric/Desktop/UIUC/SP 2021/ECE 411/Core-i9000/hvl/software_model.sv}
vlog -sv -work work +incdir+C:/Users/Eric/Desktop/UIUC/SP\ 2021/ECE\ 411/Core-i9000/hdl/types {C:/Users/Eric/Desktop/UIUC/SP 2021/ECE 411/Core-i9000/hdl/types/rv32i_types.sv}
vlog -sv -work work +incdir+C:/Users/Eric/Desktop/UIUC/SP\ 2021/ECE\ 411/Core-i9000/hdl/types {C:/Users/Eric/Desktop/UIUC/SP 2021/ECE 411/Core-i9000/hdl/types/rv32i_mux_types.sv}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L arriaii_hssi_ver -L arriaii_pcie_hip_ver -L arriaii_ver -L rtl_work -L work -voptargs="+acc"  mp4_tb

add wave *
view structure
view signals
run -all
