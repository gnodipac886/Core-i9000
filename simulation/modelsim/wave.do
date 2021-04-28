onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /mp4_tb/dut/cpu/clk
add wave -noupdate /mp4_tb/dut/cpu/rst
add wave -noupdate -group cpu_io /mp4_tb/dut/cpu/i_mem_resp
add wave -noupdate -group cpu_io /mp4_tb/dut/cpu/i_mem_rdata
add wave -noupdate -group cpu_io /mp4_tb/dut/cpu/i_mem_read
add wave -noupdate -group cpu_io /mp4_tb/dut/cpu/i_mem_write
add wave -noupdate -group cpu_io /mp4_tb/dut/cpu/i_mem_byte_enable
add wave -noupdate -group cpu_io /mp4_tb/dut/cpu/i_mem_address
add wave -noupdate -group cpu_io /mp4_tb/dut/cpu/i_mem_wdata
add wave -noupdate -group cpu_io /mp4_tb/dut/cpu/iq_empty
add wave -noupdate -group cpu_io /mp4_tb/dut/cpu/lsq_mem_resp
add wave -noupdate -group cpu_io /mp4_tb/dut/cpu/lsq_mem_rdata
add wave -noupdate -group cpu_io /mp4_tb/dut/cpu/lsq_mem_read
add wave -noupdate -group cpu_io /mp4_tb/dut/cpu/lsq_mem_write
add wave -noupdate -group cpu_io /mp4_tb/dut/cpu/lsq_mem_byte_enable
add wave -noupdate -group cpu_io /mp4_tb/dut/cpu/lsq_mem_address
add wave -noupdate -group cpu_io /mp4_tb/dut/cpu/lsq_mem_wdata
add wave -noupdate -group arbiter /mp4_tb/dut/arbiter/state
add wave -noupdate -group arbiter /mp4_tb/dut/arbiter/next_state
add wave -noupdate -group arbiter /mp4_tb/dut/arbiter/iq_empty
add wave -noupdate -group arbiter -group instruction /mp4_tb/dut/arbiter/i_pmem_read_cla
add wave -noupdate -group arbiter -group instruction /mp4_tb/dut/arbiter/i_pmem_write_cla
add wave -noupdate -group arbiter -group instruction /mp4_tb/dut/arbiter/i_pmem_address_cla
add wave -noupdate -group arbiter -group instruction /mp4_tb/dut/arbiter/i_pmem_wdata_256_cla
add wave -noupdate -group arbiter -group instruction /mp4_tb/dut/arbiter/i_pmem_resp_cla
add wave -noupdate -group arbiter -group instruction /mp4_tb/dut/arbiter/i_pmem_rdata_256_cla
add wave -noupdate -group arbiter -expand -group lsq /mp4_tb/dut/arbiter/lsq_pmem_read_cla
add wave -noupdate -group arbiter -expand -group lsq /mp4_tb/dut/arbiter/lsq_pmem_write_cla
add wave -noupdate -group arbiter -expand -group lsq /mp4_tb/dut/arbiter/lsq_pmem_address_cla
add wave -noupdate -group arbiter -expand -group lsq /mp4_tb/dut/arbiter/lsq_pmem_wdata_256_cla
add wave -noupdate -group arbiter -expand -group lsq /mp4_tb/dut/arbiter/lsq_pmem_resp_cla
add wave -noupdate -group arbiter -expand -group lsq /mp4_tb/dut/arbiter/lsq_pmem_rdata_256_cla
add wave -noupdate -group arbiter -group p_mem /mp4_tb/dut/arbiter/pmem_resp_cla
add wave -noupdate -group arbiter -group p_mem /mp4_tb/dut/arbiter/pmem_rdata_256_cla
add wave -noupdate -group arbiter -group p_mem /mp4_tb/dut/arbiter/pmem_read_cla
add wave -noupdate -group arbiter -group p_mem /mp4_tb/dut/arbiter/pmem_write_cla
add wave -noupdate -group arbiter -group p_mem /mp4_tb/dut/arbiter/pmem_address_cla
add wave -noupdate -group arbiter -group p_mem /mp4_tb/dut/arbiter/pmem_wdata_256_cla
add wave -noupdate -expand -group pc_reg /mp4_tb/dut/cpu/pc_reg/load
add wave -noupdate -expand -group pc_reg /mp4_tb/dut/cpu/pc_load
add wave -noupdate -expand -group pc_reg /mp4_tb/dut/cpu/pc_out
add wave -noupdate -expand -group pc_reg /mp4_tb/dut/cpu/fake_pc
add wave -noupdate -expand -group pc_reg /mp4_tb/dut/cpu/iq_br
add wave -noupdate -expand -group pc_reg /mp4_tb/dut/cpu/pc_mux_sel
add wave -noupdate -expand -group pc_reg /mp4_tb/dut/cpu/pc_mux_out
add wave -noupdate -expand -group pc_reg /mp4_tb/dut/cpu/br_next_pc
add wave -noupdate -expand -group pc_reg /mp4_tb/dut/cpu/rob_front
add wave -noupdate -group fetcher /mp4_tb/dut/cpu/fetcher/deq
add wave -noupdate -group fetcher /mp4_tb/dut/cpu/fetcher/pc_addr
add wave -noupdate -group fetcher /mp4_tb/dut/cpu/fetcher/rdy
add wave -noupdate -group fetcher /mp4_tb/dut/cpu/fetcher/out
add wave -noupdate -group fetcher /mp4_tb/dut/cpu/fetcher/i_mem_resp
add wave -noupdate -group fetcher /mp4_tb/dut/cpu/fetcher/i_mem_rdata
add wave -noupdate -group fetcher /mp4_tb/dut/cpu/fetcher/i_mem_read
add wave -noupdate -group fetcher /mp4_tb/dut/cpu/fetcher/i_mem_address
add wave -noupdate -group decoder /mp4_tb/dut/cpu/decoder/instruction
add wave -noupdate -group decoder /mp4_tb/dut/cpu/decoder/pc
add wave -noupdate -group decoder /mp4_tb/dut/cpu/decoder/decoder_out
add wave -noupdate -group decoder /mp4_tb/dut/cpu/decoder/data
add wave -noupdate -group decoder -expand /mp4_tb/dut/cpu/decoder/pci
add wave -noupdate -group iq /mp4_tb/dut/cpu/iq/arr
add wave -noupdate -group iq /mp4_tb/dut/cpu/iq/enq
add wave -noupdate -group iq /mp4_tb/dut/cpu/iq/deq
add wave -noupdate -group iq /mp4_tb/dut/cpu/iq/in
add wave -noupdate -group iq /mp4_tb/dut/cpu/iq/empty
add wave -noupdate -group iq /mp4_tb/dut/cpu/iq/full
add wave -noupdate -group iq /mp4_tb/dut/cpu/iq/ready
add wave -noupdate -group iq /mp4_tb/dut/cpu/iq/out
add wave -noupdate -group iq /mp4_tb/dut/cpu/iq/front
add wave -noupdate -group iq /mp4_tb/dut/cpu/iq/rear
add wave -noupdate -group rob -group rob_imm /mp4_tb/dut/cpu/rob/arr
add wave -noupdate -group rob -group rob_imm /mp4_tb/dut/cpu/rob/acu_rs_o
add wave -noupdate -group rob -group rob_imm /mp4_tb/dut/cpu/rob/br_rs_o
add wave -noupdate -group rob -group rob_imm /mp4_tb/dut/cpu/rob/lsq_o
add wave -noupdate -group rob -group rob_imm /mp4_tb/dut/cpu/rob/rob_broadcast_bus
add wave -noupdate -group rob -group rob_imm /mp4_tb/dut/cpu/rob/front
add wave -noupdate -group rob -group rob_imm /mp4_tb/dut/cpu/rob/rear
add wave -noupdate -group rob -group rob_imm /mp4_tb/dut/cpu/rob/flush
add wave -noupdate -group rob -group rob_imm /mp4_tb/dut/cpu/rob/flush_pc
add wave -noupdate -group rob -group rob_unimm /mp4_tb/dut/cpu/rob/rob_front
add wave -noupdate -group rob -group rob_unimm /mp4_tb/dut/cpu/rob/instr_q_dequeue
add wave -noupdate -group rob -group rob_unimm /mp4_tb/dut/cpu/rob/instr_q_empty
add wave -noupdate -group rob -group rob_unimm /mp4_tb/dut/cpu/rob/pci
add wave -noupdate -group rob -group rob_unimm /mp4_tb/dut/cpu/rob/stall_br
add wave -noupdate -group rob -group rob_unimm /mp4_tb/dut/cpu/rob/stall_lsq
add wave -noupdate -group rob -group rob_unimm /mp4_tb/dut/cpu/rob/stall_acu
add wave -noupdate -group rob -group rob_unimm /mp4_tb/dut/cpu/rob/load_br_rs
add wave -noupdate -group rob -group rob_unimm /mp4_tb/dut/cpu/rob/load_lsq
add wave -noupdate -group rob -group rob_unimm /mp4_tb/dut/cpu/rob/rdest
add wave -noupdate -group rob -group rob_unimm /mp4_tb/dut/cpu/rob/rd_tag
add wave -noupdate -group rob -group rob_unimm /mp4_tb/dut/cpu/rob/temp_in
add wave -noupdate -group rob -group rob_unimm /mp4_tb/dut/cpu/rob/enq
add wave -noupdate -group rob -group rob_unimm /mp4_tb/dut/cpu/rob/deq
add wave -noupdate -group rob -group rob_unimm /mp4_tb/dut/cpu/rob/full
add wave -noupdate -group rob -group rob_unimm /mp4_tb/dut/cpu/rob/empty
add wave -noupdate -group rob -group rob_unimm /mp4_tb/dut/cpu/rob/flush_tag
add wave -noupdate -group rob -group rob_unimm /mp4_tb/dut/cpu/rob/num_deq
add wave -noupdate -expand -group sm /mp4_tb/sm/cpu_registers
add wave -noupdate -expand -group sm /mp4_tb/sm/data
add wave -noupdate -expand -group sm /mp4_tb/sm/pc
add wave -noupdate -expand -group sm /mp4_tb/sm/pc_out
add wave -noupdate -expand -group sm /mp4_tb/sm/commit
add wave -noupdate -expand -group sm /mp4_tb/sm/rdest
add wave -noupdate -expand -group sm /mp4_tb/sm/r1_data
add wave -noupdate -expand -group sm /mp4_tb/sm/r2_data
add wave -noupdate -group reg_file -expand /mp4_tb/dut/cpu/registers/data
add wave -noupdate -group reg_file -expand /mp4_tb/dut/cpu/registers/rdest
add wave -noupdate -group reg_file /mp4_tb/dut/cpu/registers/rd_bus
add wave -noupdate -group reg_file /mp4_tb/dut/cpu/registers/reg_ld_instr
add wave -noupdate -group reg_file /mp4_tb/dut/cpu/registers/rd_tag
add wave -noupdate -group reg_file /mp4_tb/dut/cpu/registers/rs1
add wave -noupdate -group reg_file /mp4_tb/dut/cpu/registers/rs2
add wave -noupdate -group reg_file /mp4_tb/dut/cpu/registers/rd
add wave -noupdate -group reg_file /mp4_tb/dut/cpu/registers/rs_out
add wave -noupdate -group lsq -expand -group lsq_imm -expand -subitemconfig {{/mp4_tb/dut/cpu/lsq/arr[0]} -expand} /mp4_tb/dut/cpu/lsq/arr
add wave -noupdate -group lsq -expand -group lsq_imm /mp4_tb/dut/cpu/lsq/lsq_out
add wave -noupdate -group lsq -expand -group lsq_imm /mp4_tb/dut/cpu/lsq/mem_resp
add wave -noupdate -group lsq -expand -group lsq_imm /mp4_tb/dut/cpu/lsq/mem_rdata
add wave -noupdate -group lsq -expand -group lsq_imm /mp4_tb/dut/cpu/lsq/mem_read
add wave -noupdate -group lsq -expand -group lsq_imm /mp4_tb/dut/cpu/lsq/mem_write
add wave -noupdate -group lsq -expand -group lsq_imm /mp4_tb/dut/cpu/lsq/mem_address
add wave -noupdate -group lsq -expand -group lsq_imm /mp4_tb/dut/cpu/lsq/remainder
add wave -noupdate -group lsq -expand -group lsq_imm /mp4_tb/dut/cpu/lsq/mem_address_raw
add wave -noupdate -group lsq -expand -group lsq_imm /mp4_tb/dut/cpu/lsq/next_front
add wave -noupdate -group lsq -expand -group lsq_imm /mp4_tb/dut/cpu/lsq/front
add wave -noupdate -group lsq -expand -group lsq_imm /mp4_tb/dut/cpu/lsq/rear
add wave -noupdate -group lsq -group lsq_unimm /mp4_tb/dut/cpu/lsq/rob_bus
add wave -noupdate -group lsq -group lsq_unimm /mp4_tb/dut/cpu/lsq/reg_entry
add wave -noupdate -group lsq -group lsq_unimm /mp4_tb/dut/cpu/lsq/instruction
add wave -noupdate -group lsq -group lsq_unimm /mp4_tb/dut/cpu/lsq/rob_tag
add wave -noupdate -group lsq -group lsq_unimm /mp4_tb/dut/cpu/lsq/lsq_stall
add wave -noupdate -group lsq -group lsq_unimm /mp4_tb/dut/cpu/lsq/mem_byte_enable
add wave -noupdate -group lsq -group lsq_unimm /mp4_tb/dut/cpu/lsq/mem_wdata
add wave -noupdate -group lsq -group lsq_unimm /mp4_tb/dut/cpu/lsq/front_is_ld
add wave -noupdate -group lsq -group lsq_unimm /mp4_tb/dut/cpu/lsq/shift_amt
add wave -noupdate -group lsq -group lsq_unimm /mp4_tb/dut/cpu/lsq/mem_rdata_shifted
add wave -noupdate -group lsq -group lsq_unimm /mp4_tb/dut/cpu/lsq/lsq_enq
add wave -noupdate -group lsq -group lsq_unimm /mp4_tb/dut/cpu/lsq/lsq_deq
add wave -noupdate -group lsq -group lsq_unimm /mp4_tb/dut/cpu/lsq/lsq_empty
add wave -noupdate -group lsq -group lsq_unimm /mp4_tb/dut/cpu/lsq/lsq_full
add wave -noupdate -group lsq -group lsq_unimm /mp4_tb/dut/cpu/lsq/lsq_ready
add wave -noupdate -group lsq -group lsq_unimm /mp4_tb/dut/cpu/lsq/is_lsq_instr
add wave -noupdate -group lsq -group lsq_unimm /mp4_tb/dut/cpu/lsq/is_ld_instr
add wave -noupdate -group lsq -group lsq_unimm /mp4_tb/dut/cpu/lsq/is_st_instr
add wave -noupdate -group lsq -group lsq_unimm /mp4_tb/dut/cpu/lsq/lsq_in
add wave -noupdate -group lsq -group lsq_unimm /mp4_tb/dut/cpu/lsq/lsq_front
add wave -noupdate -group lsq -group lsq_unimm /mp4_tb/dut/cpu/lsq/ld_byte_en
add wave -noupdate -group lsq -group lsq_unimm /mp4_tb/dut/cpu/lsq/enq
add wave -noupdate -group lsq -group lsq_unimm /mp4_tb/dut/cpu/lsq/deq
add wave -noupdate -group lsq -group lsq_unimm /mp4_tb/dut/cpu/lsq/in
add wave -noupdate -group lsq -group lsq_unimm /mp4_tb/dut/cpu/lsq/empty
add wave -noupdate -group lsq -group lsq_unimm /mp4_tb/dut/cpu/lsq/full
add wave -noupdate -group lsq -group lsq_unimm /mp4_tb/dut/cpu/lsq/ready
add wave -noupdate -group lsq -group lsq_unimm /mp4_tb/dut/cpu/lsq/out
add wave -noupdate -group lsq -group lsq_unimm /mp4_tb/dut/cpu/lsq/next_front_is_ld
add wave -noupdate -group lsq -group lsq_unimm /mp4_tb/dut/cpu/lsq/next_front_is_valid
add wave -noupdate -group lsq -group lsq_unimm /mp4_tb/dut/cpu/lsq/front_is_valid
add wave -noupdate -group alu_acu /mp4_tb/dut/cpu/acu_module/data
add wave -noupdate -group alu_acu /mp4_tb/dut/cpu/acu_module/ready
add wave -noupdate -group alu_acu /mp4_tb/dut/cpu/acu_module/acu_operation
add wave -noupdate -group alu_acu /mp4_tb/dut/cpu/acu_module/out
add wave -noupdate -group alu_acu /mp4_tb/dut/cpu/acu_module/out_alu
add wave -noupdate -group alu_acu /mp4_tb/dut/cpu/acu_module/out_cmp
add wave -noupdate -group acu_rs /mp4_tb/dut/cpu/acu_rs/data
add wave -noupdate -group acu_rs /mp4_tb/dut/cpu/acu_rs/input_r
add wave -noupdate -group acu_rs /mp4_tb/dut/cpu/acu_rs/broadcast_bus
add wave -noupdate -group acu_rs /mp4_tb/dut/cpu/acu_rs/rob_broadcast_bus
add wave -noupdate -group acu_rs /mp4_tb/dut/cpu/acu_rs/flush
add wave -noupdate -group acu_rs /mp4_tb/dut/cpu/acu_rs/load
add wave -noupdate -group acu_rs /mp4_tb/dut/cpu/acu_rs/tag
add wave -noupdate -group acu_rs /mp4_tb/dut/cpu/acu_rs/pci
add wave -noupdate -group acu_rs /mp4_tb/dut/cpu/acu_rs/acu_operation
add wave -noupdate -group acu_rs /mp4_tb/dut/cpu/acu_rs/ready
add wave -noupdate -group acu_rs /mp4_tb/dut/cpu/acu_rs/num_available
add wave -noupdate -group acu_rs /mp4_tb/dut/cpu/acu_rs/next_rs
add wave -noupdate -group acu_rs /mp4_tb/dut/cpu/acu_rs/index
add wave -noupdate -group br_rs /mp4_tb/dut/cpu/br_rs/data
add wave -noupdate -group br_rs /mp4_tb/dut/cpu/br_rs/input_r
add wave -noupdate -group br_rs /mp4_tb/dut/cpu/br_rs/broadcast_bus
add wave -noupdate -group br_rs /mp4_tb/dut/cpu/br_rs/rob_broadcast_bus
add wave -noupdate -group br_rs /mp4_tb/dut/cpu/br_rs/flush
add wave -noupdate -group br_rs /mp4_tb/dut/cpu/br_rs/load
add wave -noupdate -group br_rs /mp4_tb/dut/cpu/br_rs/tag
add wave -noupdate -group br_rs /mp4_tb/dut/cpu/br_rs/pci
add wave -noupdate -group br_rs /mp4_tb/dut/cpu/br_rs/acu_operation
add wave -noupdate -group br_rs /mp4_tb/dut/cpu/br_rs/ready
add wave -noupdate -group br_rs /mp4_tb/dut/cpu/br_rs/num_available
add wave -noupdate -group br_rs /mp4_tb/dut/cpu/br_rs/next_rs
add wave -noupdate -group br_rs /mp4_tb/dut/cpu/br_rs/index
add wave -noupdate -group br_acu /mp4_tb/dut/cpu/acu_br/data
add wave -noupdate -group br_acu /mp4_tb/dut/cpu/acu_br/ready
add wave -noupdate -group br_acu /mp4_tb/dut/cpu/acu_br/acu_operation
add wave -noupdate -group br_acu -expand -subitemconfig {{/mp4_tb/dut/cpu/acu_br/out[0]} -expand} /mp4_tb/dut/cpu/acu_br/out
add wave -noupdate -group br_acu /mp4_tb/dut/cpu/acu_br/out_alu
add wave -noupdate -group br_acu /mp4_tb/dut/cpu/acu_br/out_cmp
add wave -noupdate -group br_pred /mp4_tb/dut/cpu/br_pred/pc_info
add wave -noupdate -group br_pred /mp4_tb/dut/cpu/br_pred/br_result
add wave -noupdate -group br_pred /mp4_tb/dut/cpu/br_pred/pc_result
add wave -noupdate -group br_pred /mp4_tb/dut/cpu/br_pred/pc_result_load
add wave -noupdate -group br_pred /mp4_tb/dut/cpu/br_pred/br_taken
add wave -noupdate -group br_pred /mp4_tb/dut/cpu/br_pred/br_addr
add wave -noupdate -group br_pred /mp4_tb/dut/cpu/br_pred/arr
add wave -noupdate -group br_pred /mp4_tb/dut/cpu/br_pred/arr_idx
add wave -noupdate -group br_pred /mp4_tb/dut/cpu/br_pred/result_idx
add wave -noupdate -group br_pred /mp4_tb/dut/cpu/br_pred/hit
add wave -noupdate -group br_pred /mp4_tb/dut/cpu/br_pred/hit_idx
add wave -noupdate -group lsq_cache -expand -group io /mp4_tb/dut/lsq_cache/pmem_resp
add wave -noupdate -group lsq_cache -expand -group io /mp4_tb/dut/lsq_cache/pmem_rdata
add wave -noupdate -group lsq_cache -expand -group io /mp4_tb/dut/lsq_cache/pmem_address
add wave -noupdate -group lsq_cache -expand -group io /mp4_tb/dut/lsq_cache/pmem_wdata
add wave -noupdate -group lsq_cache -expand -group io /mp4_tb/dut/lsq_cache/pmem_read
add wave -noupdate -group lsq_cache -expand -group io /mp4_tb/dut/lsq_cache/pmem_write
add wave -noupdate -group lsq_cache -expand -group io /mp4_tb/dut/lsq_cache/mem_read
add wave -noupdate -group lsq_cache -expand -group io /mp4_tb/dut/lsq_cache/mem_write
add wave -noupdate -group lsq_cache -expand -group io /mp4_tb/dut/lsq_cache/mem_byte_enable_cpu
add wave -noupdate -group lsq_cache -expand -group io /mp4_tb/dut/lsq_cache/mem_address
add wave -noupdate -group lsq_cache -expand -group io /mp4_tb/dut/lsq_cache/mem_wdata_cpu
add wave -noupdate -group lsq_cache -expand -group io /mp4_tb/dut/lsq_cache/mem_resp
add wave -noupdate -group lsq_cache -expand -group io /mp4_tb/dut/lsq_cache/mem_rdata_cpu
add wave -noupdate -group lsq_cache -expand -group io /mp4_tb/dut/lsq_cache/hit
add wave -noupdate -group lsq_cache -expand -group io /mp4_tb/dut/lsq_cache/writing
add wave -noupdate -group lsq_cache -expand -group io /mp4_tb/dut/lsq_cache/mem_wdata
add wave -noupdate -group lsq_cache -expand -group io /mp4_tb/dut/lsq_cache/mem_rdata
add wave -noupdate -group lsq_cache -expand -group io /mp4_tb/dut/lsq_cache/mem_byte_enable
add wave -noupdate -group lsq_cache /mp4_tb/dut/lsq_cache/control/state
add wave -noupdate -group lsq_cache /mp4_tb/dut/lsq_cache/control/next_state
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {123968 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 338
configure wave -valuecolwidth 81
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {630 ns}
