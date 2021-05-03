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
add wave -noupdate -expand -group arbiter /mp4_tb/dut/arbiter/state
add wave -noupdate -expand -group arbiter /mp4_tb/dut/arbiter/next_state
add wave -noupdate -expand -group arbiter /mp4_tb/dut/arbiter/iq_empty
add wave -noupdate -expand -group arbiter -group instruction /mp4_tb/dut/arbiter/i_pmem_read_cla
add wave -noupdate -expand -group arbiter -group instruction /mp4_tb/dut/arbiter/i_pmem_write_cla
add wave -noupdate -expand -group arbiter -group instruction /mp4_tb/dut/arbiter/i_pmem_address_cla
add wave -noupdate -expand -group arbiter -group instruction /mp4_tb/dut/arbiter/i_pmem_wdata_256_cla
add wave -noupdate -expand -group arbiter -group instruction /mp4_tb/dut/arbiter/i_pmem_resp_cla
add wave -noupdate -expand -group arbiter -group instruction /mp4_tb/dut/arbiter/i_pmem_rdata_256_cla
add wave -noupdate -expand -group arbiter -group lsq /mp4_tb/dut/arbiter/lsq_pmem_read_cla
add wave -noupdate -expand -group arbiter -group lsq /mp4_tb/dut/arbiter/lsq_pmem_write_cla
add wave -noupdate -expand -group arbiter -group lsq /mp4_tb/dut/arbiter/lsq_pmem_address_cla
add wave -noupdate -expand -group arbiter -group lsq /mp4_tb/dut/arbiter/lsq_pmem_wdata_256_cla
add wave -noupdate -expand -group arbiter -group lsq /mp4_tb/dut/arbiter/lsq_pmem_resp_cla
add wave -noupdate -expand -group arbiter -group lsq /mp4_tb/dut/arbiter/lsq_pmem_rdata_256_cla
add wave -noupdate -expand -group arbiter -expand -group p_mem /mp4_tb/dut/arbiter/pmem_resp_cla
add wave -noupdate -expand -group arbiter -expand -group p_mem /mp4_tb/dut/arbiter/pmem_rdata_256_cla
add wave -noupdate -expand -group arbiter -expand -group p_mem /mp4_tb/dut/arbiter/pmem_read_cla
add wave -noupdate -expand -group arbiter -expand -group p_mem /mp4_tb/dut/arbiter/pmem_write_cla
add wave -noupdate -expand -group arbiter -expand -group p_mem /mp4_tb/dut/arbiter/pmem_address_cla
add wave -noupdate -expand -group arbiter -expand -group p_mem /mp4_tb/dut/arbiter/pmem_wdata_256_cla
add wave -noupdate -group pc_reg /mp4_tb/dut/cpu/pc_reg/load
add wave -noupdate -group pc_reg /mp4_tb/dut/cpu/pc_load
add wave -noupdate -group pc_reg /mp4_tb/dut/cpu/pc_out
add wave -noupdate -group pc_reg /mp4_tb/dut/cpu/comp3_pc
add wave -noupdate -group pc_reg /mp4_tb/dut/cpu/comp1_pc
add wave -noupdate -group pc_reg /mp4_tb/dut/cpu/fake_pc
add wave -noupdate -group pc_reg /mp4_tb/dut/cpu/iq_br
add wave -noupdate -group pc_reg /mp4_tb/dut/cpu/pc_mux_sel
add wave -noupdate -group pc_reg /mp4_tb/dut/cpu/pc_mux_out
add wave -noupdate -group pc_reg /mp4_tb/dut/cpu/br_next_pc
add wave -noupdate -group pc_reg /mp4_tb/dut/cpu/rob_front
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
add wave -noupdate -group rob -expand -group rob_imm /mp4_tb/dut/cpu/rob/arr
add wave -noupdate -group rob -expand -group rob_imm /mp4_tb/dut/cpu/rob/acu_rs_o
add wave -noupdate -group rob -expand -group rob_imm /mp4_tb/dut/cpu/rob/br_rs_o
add wave -noupdate -group rob -expand -group rob_imm /mp4_tb/dut/cpu/rob/lsq_o
add wave -noupdate -group rob -expand -group rob_imm /mp4_tb/dut/cpu/rob/rob_broadcast_bus
add wave -noupdate -group rob -expand -group rob_imm /mp4_tb/dut/cpu/rob/front
add wave -noupdate -group rob -expand -group rob_imm /mp4_tb/dut/cpu/rob/rear
add wave -noupdate -group rob -expand -group rob_imm -expand /mp4_tb/dut/cpu/rob/flush
add wave -noupdate -group rob -expand -group rob_imm /mp4_tb/dut/cpu/rob/flush_pc
add wave -noupdate -group rob -expand -group rob_unimm /mp4_tb/dut/cpu/rob/rob_front
add wave -noupdate -group rob -expand -group rob_unimm /mp4_tb/dut/cpu/rob/instr_q_dequeue
add wave -noupdate -group rob -expand -group rob_unimm /mp4_tb/dut/cpu/rob/instr_q_empty
add wave -noupdate -group rob -expand -group rob_unimm /mp4_tb/dut/cpu/rob/pci
add wave -noupdate -group rob -expand -group rob_unimm /mp4_tb/dut/cpu/rob/stall_br
add wave -noupdate -group rob -expand -group rob_unimm /mp4_tb/dut/cpu/rob/stall_lsq
add wave -noupdate -group rob -expand -group rob_unimm /mp4_tb/dut/cpu/rob/stall_acu
add wave -noupdate -group rob -expand -group rob_unimm /mp4_tb/dut/cpu/rob/load_br_rs
add wave -noupdate -group rob -expand -group rob_unimm /mp4_tb/dut/cpu/rob/load_lsq
add wave -noupdate -group rob -expand -group rob_unimm /mp4_tb/dut/cpu/rob/test_signal
add wave -noupdate -group rob -expand -group rob_unimm /mp4_tb/dut/cpu/rob/rdest
add wave -noupdate -group rob -expand -group rob_unimm /mp4_tb/dut/cpu/rob/rd_bus
add wave -noupdate -group rob -expand -group rob_unimm /mp4_tb/dut/cpu/rob/rd_tag
add wave -noupdate -group rob -expand -group rob_unimm /mp4_tb/dut/cpu/rob/temp_in
add wave -noupdate -group rob -expand -group rob_unimm /mp4_tb/dut/cpu/rob/enq
add wave -noupdate -group rob -expand -group rob_unimm /mp4_tb/dut/cpu/rob/deq
add wave -noupdate -group rob -expand -group rob_unimm /mp4_tb/dut/cpu/rob/full
add wave -noupdate -group rob -expand -group rob_unimm /mp4_tb/dut/cpu/rob/empty
add wave -noupdate -group rob -expand -group rob_unimm /mp4_tb/dut/cpu/rob/flush_tag
add wave -noupdate -group rob -expand -group rob_unimm /mp4_tb/dut/cpu/rob/num_deq
add wave -noupdate -group sm /mp4_tb/sm/cpu_registers
add wave -noupdate -group sm /mp4_tb/sm/data
add wave -noupdate -group sm /mp4_tb/sm/commit
add wave -noupdate -group sm /mp4_tb/sm/rdest
add wave -noupdate -group sm /mp4_tb/sm/r1_data
add wave -noupdate -group sm /mp4_tb/sm/r2_data
add wave -noupdate -group sm /mp4_tb/sm/pc
add wave -noupdate -group sm /mp4_tb/sm/pc_hist
add wave -noupdate -group sm /mp4_tb/sm/sm_pc
add wave -noupdate -group sm /mp4_tb/sm/sm_inst
add wave -noupdate -group sm /mp4_tb/sm/pci
add wave -noupdate -group sm /mp4_tb/sm/num_commit
add wave -noupdate -group sm /mp4_tb/sm/flush
add wave -noupdate -group sm /mp4_tb/sm/pc_load
add wave -noupdate -group sm /mp4_tb/sm/pc_mux_out
add wave -noupdate -group sm /mp4_tb/sm/num_deq
add wave -noupdate -group sm /mp4_tb/sm/cpu_pci
add wave -noupdate -group sm /mp4_tb/sm/take_pc
add wave -noupdate -group reg_file -expand /mp4_tb/dut/cpu/registers/data
add wave -noupdate -group reg_file -expand /mp4_tb/dut/cpu/registers/rdest
add wave -noupdate -group reg_file /mp4_tb/dut/cpu/registers/rd_bus
add wave -noupdate -group reg_file /mp4_tb/dut/cpu/registers/reg_ld_instr
add wave -noupdate -group reg_file /mp4_tb/dut/cpu/registers/rd_tag
add wave -noupdate -group reg_file /mp4_tb/dut/cpu/registers/rs1
add wave -noupdate -group reg_file /mp4_tb/dut/cpu/registers/rs2
add wave -noupdate -group reg_file /mp4_tb/dut/cpu/registers/rd
add wave -noupdate -group reg_file /mp4_tb/dut/cpu/registers/rs_out
add wave -noupdate -group lsq -expand -group lsq_imm -expand /mp4_tb/dut/cpu/lsq/arr
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
add wave -noupdate -group i_cache -group datapath -expand -group io /mp4_tb/dut/i_cache/datapath/mem_byte_enable
add wave -noupdate -group i_cache -group datapath -expand -group io /mp4_tb/dut/i_cache/datapath/mem_address
add wave -noupdate -group i_cache -group datapath -expand -group io /mp4_tb/dut/i_cache/datapath/mem_wdata
add wave -noupdate -group i_cache -group datapath -expand -group io /mp4_tb/dut/i_cache/datapath/mem_rdata
add wave -noupdate -group i_cache -group datapath -expand -group io /mp4_tb/dut/i_cache/datapath/pmem_rdata
add wave -noupdate -group i_cache -group datapath -expand -group io /mp4_tb/dut/i_cache/datapath/pmem_wdata
add wave -noupdate -group i_cache -group datapath -expand -group io /mp4_tb/dut/i_cache/datapath/pmem_address
add wave -noupdate -group i_cache -group datapath -expand -group io /mp4_tb/dut/i_cache/datapath/tag_load
add wave -noupdate -group i_cache -group datapath -expand -group io /mp4_tb/dut/i_cache/datapath/valid_load
add wave -noupdate -group i_cache -group datapath -expand -group io /mp4_tb/dut/i_cache/datapath/dirty_load
add wave -noupdate -group i_cache -group datapath -expand -group io /mp4_tb/dut/i_cache/datapath/dirty_in
add wave -noupdate -group i_cache -group datapath -expand -group io /mp4_tb/dut/i_cache/datapath/dirty_out
add wave -noupdate -group i_cache -group datapath -expand -group io /mp4_tb/dut/i_cache/datapath/hit
add wave -noupdate -group i_cache -group datapath -expand -group io /mp4_tb/dut/i_cache/datapath/writing
add wave -noupdate -group i_cache -group datapath -group others /mp4_tb/dut/i_cache/datapath/_idx
add wave -noupdate -group i_cache -group datapath -group others /mp4_tb/dut/i_cache/datapath/_tag_load
add wave -noupdate -group i_cache -group datapath -group others /mp4_tb/dut/i_cache/datapath/_valid_load
add wave -noupdate -group i_cache -group datapath -group others /mp4_tb/dut/i_cache/datapath/_dirty_load
add wave -noupdate -group i_cache -group datapath -group others /mp4_tb/dut/i_cache/datapath/_dirty_out
add wave -noupdate -group i_cache -group datapath -group others /mp4_tb/dut/i_cache/datapath/_hit
add wave -noupdate -group i_cache -group datapath -group others /mp4_tb/dut/i_cache/datapath/line_in
add wave -noupdate -group i_cache -group datapath -group others /mp4_tb/dut/i_cache/datapath/line_out
add wave -noupdate -group i_cache -group datapath -group others /mp4_tb/dut/i_cache/datapath/address_tag
add wave -noupdate -group i_cache -group datapath -group others /mp4_tb/dut/i_cache/datapath/tag_out
add wave -noupdate -group i_cache -group datapath -group others -expand /mp4_tb/dut/i_cache/datapath/mask
add wave -noupdate -group i_cache -group datapath -group others /mp4_tb/dut/i_cache/datapath/valid_out
add wave -noupdate -group i_cache -group datapath -group others /mp4_tb/dut/i_cache/datapath/lru_load
add wave -noupdate -group i_cache -group datapath -group others /mp4_tb/dut/i_cache/datapath/lru_in
add wave -noupdate -group i_cache -group datapath -group others /mp4_tb/dut/i_cache/datapath/lru_out
add wave -noupdate -group i_cache -group datapath -group others {/mp4_tb/dut/i_cache/datapath/multiple_way_arrays[1]/valid/data}
add wave -noupdate -group i_cache -group datapath -group others {/mp4_tb/dut/i_cache/datapath/multiple_way_arrays[0]/valid/data}
add wave -noupdate -group i_cache -group control /mp4_tb/dut/i_cache/control/mem_read
add wave -noupdate -group i_cache -group control /mp4_tb/dut/i_cache/control/mem_write
add wave -noupdate -group i_cache -group control /mp4_tb/dut/i_cache/control/mem_resp
add wave -noupdate -group i_cache -group control /mp4_tb/dut/i_cache/control/pmem_resp
add wave -noupdate -group i_cache -group control /mp4_tb/dut/i_cache/control/pmem_read
add wave -noupdate -group i_cache -group control /mp4_tb/dut/i_cache/control/pmem_write
add wave -noupdate -group i_cache -group control /mp4_tb/dut/i_cache/control/tag_load
add wave -noupdate -group i_cache -group control /mp4_tb/dut/i_cache/control/valid_load
add wave -noupdate -group i_cache -group control /mp4_tb/dut/i_cache/control/dirty_load
add wave -noupdate -group i_cache -group control /mp4_tb/dut/i_cache/control/dirty_in
add wave -noupdate -group i_cache -group control /mp4_tb/dut/i_cache/control/dirty_out
add wave -noupdate -group i_cache -group control /mp4_tb/dut/i_cache/control/hit
add wave -noupdate -group i_cache -group control /mp4_tb/dut/i_cache/control/writing
add wave -noupdate -group i_cache -group control /mp4_tb/dut/i_cache/control/state
add wave -noupdate -group i_cache -group control /mp4_tb/dut/i_cache/control/next_state
add wave -noupdate -group i_cache -group data_arr_0 {/mp4_tb/dut/i_cache/datapath/multiple_way_arrays[0]/DM_cache/write_en}
add wave -noupdate -group i_cache -group data_arr_0 {/mp4_tb/dut/i_cache/datapath/multiple_way_arrays[0]/DM_cache/rindex}
add wave -noupdate -group i_cache -group data_arr_0 {/mp4_tb/dut/i_cache/datapath/multiple_way_arrays[0]/DM_cache/windex}
add wave -noupdate -group i_cache -group data_arr_0 {/mp4_tb/dut/i_cache/datapath/multiple_way_arrays[0]/DM_cache/datain}
add wave -noupdate -group i_cache -group data_arr_0 {/mp4_tb/dut/i_cache/datapath/multiple_way_arrays[0]/DM_cache/dataout}
add wave -noupdate -group i_cache -group data_arr_1 {/mp4_tb/dut/i_cache/datapath/multiple_way_arrays[1]/DM_cache/write_en}
add wave -noupdate -group i_cache -group data_arr_1 {/mp4_tb/dut/i_cache/datapath/multiple_way_arrays[1]/DM_cache/rindex}
add wave -noupdate -group i_cache -group data_arr_1 {/mp4_tb/dut/i_cache/datapath/multiple_way_arrays[1]/DM_cache/windex}
add wave -noupdate -group i_cache -group data_arr_1 {/mp4_tb/dut/i_cache/datapath/multiple_way_arrays[1]/DM_cache/datain}
add wave -noupdate -group i_cache -group data_arr_1 {/mp4_tb/dut/i_cache/datapath/multiple_way_arrays[1]/DM_cache/dataout}
add wave -noupdate -group i_cache -group valid0 {/mp4_tb/dut/i_cache/datapath/multiple_way_arrays[0]/valid/load}
add wave -noupdate -group i_cache -group valid0 {/mp4_tb/dut/i_cache/datapath/multiple_way_arrays[0]/valid/rindex}
add wave -noupdate -group i_cache -group valid0 {/mp4_tb/dut/i_cache/datapath/multiple_way_arrays[0]/valid/windex}
add wave -noupdate -group i_cache -group valid0 {/mp4_tb/dut/i_cache/datapath/multiple_way_arrays[0]/valid/datain}
add wave -noupdate -group i_cache -group valid0 {/mp4_tb/dut/i_cache/datapath/multiple_way_arrays[0]/valid/dataout}
add wave -noupdate -group i_cache -group valid0 {/mp4_tb/dut/i_cache/datapath/multiple_way_arrays[0]/valid/data}
add wave -noupdate -group i_cache -group lru0 {/mp4_tb/dut/i_cache/datapath/multiple_way_arrays[0]/lru/load}
add wave -noupdate -group i_cache -group lru0 {/mp4_tb/dut/i_cache/datapath/multiple_way_arrays[0]/lru/data}
add wave -noupdate -group i_cache -group lru0 {/mp4_tb/dut/i_cache/datapath/multiple_way_arrays[0]/lru/rindex}
add wave -noupdate -group i_cache -group lru0 {/mp4_tb/dut/i_cache/datapath/multiple_way_arrays[0]/lru/windex}
add wave -noupdate -group i_cache -group lru0 {/mp4_tb/dut/i_cache/datapath/multiple_way_arrays[0]/lru/datain}
add wave -noupdate -group i_cache -group lru0 {/mp4_tb/dut/i_cache/datapath/multiple_way_arrays[0]/lru/dataout}
add wave -noupdate -group lru {/mp4_tb/dut/lsq_cache/datapath/multiple_way_arrays[0]/lru/data}
add wave -noupdate -group lru {/mp4_tb/dut/lsq_cache/datapath/multiple_way_arrays[1]/lru/data}
add wave -noupdate -group lru {/mp4_tb/dut/lsq_cache/datapath/multiple_way_arrays[2]/lru/data}
add wave -noupdate -group lru {/mp4_tb/dut/lsq_cache/datapath/multiple_way_arrays[3]/lru/data}
add wave -noupdate -group lru {/mp4_tb/dut/lsq_cache/datapath/multiple_way_arrays[4]/lru/data}
add wave -noupdate -group lru {/mp4_tb/dut/lsq_cache/datapath/multiple_way_arrays[5]/lru/data}
add wave -noupdate -group lru {/mp4_tb/dut/lsq_cache/datapath/multiple_way_arrays[6]/lru/data}
add wave -noupdate -group lru {/mp4_tb/dut/lsq_cache/datapath/multiple_way_arrays[7]/lru/data}
add wave -noupdate -group lru {/mp4_tb/dut/lsq_cache/datapath/multiple_way_arrays[8]/lru/data}
add wave -noupdate -group lru {/mp4_tb/dut/lsq_cache/datapath/multiple_way_arrays[9]/lru/data}
add wave -noupdate -group lru {/mp4_tb/dut/lsq_cache/datapath/multiple_way_arrays[10]/lru/data}
add wave -noupdate -group lru {/mp4_tb/dut/lsq_cache/datapath/multiple_way_arrays[11]/lru/data}
add wave -noupdate -group lru {/mp4_tb/dut/lsq_cache/datapath/multiple_way_arrays[12]/lru/data}
add wave -noupdate -group lru {/mp4_tb/dut/lsq_cache/datapath/multiple_way_arrays[13]/lru/data}
add wave -noupdate -group lru {/mp4_tb/dut/lsq_cache/datapath/multiple_way_arrays[14]/lru/data}
add wave -noupdate -group lru {/mp4_tb/dut/lsq_cache/datapath/multiple_way_arrays[15]/lru/data}
add wave -noupdate -group prefetcher /mp4_tb/dut/pref/lsq_pmem_read_cla
add wave -noupdate -group prefetcher /mp4_tb/dut/pref/lsq_pmem_write_cla
add wave -noupdate -group prefetcher /mp4_tb/dut/pref/pref_pmem_resp_cla
add wave -noupdate -group prefetcher /mp4_tb/dut/pref/lsq_pmem_address_cla
add wave -noupdate -group prefetcher /mp4_tb/dut/pref/pref_pmem_rdata_256_cla
add wave -noupdate -group prefetcher /mp4_tb/dut/pref/arbiter_idle
add wave -noupdate -group prefetcher /mp4_tb/dut/pref/pref_pmem_read_cla
add wave -noupdate -group prefetcher /mp4_tb/dut/pref/pref_pmem_write_cla
add wave -noupdate -group prefetcher /mp4_tb/dut/pref/pref_pmem_address_cla
add wave -noupdate -group prefetcher /mp4_tb/dut/pref/pref_pmem_wdata_256_cla
add wave -noupdate -group prefetcher /mp4_tb/dut/pref/pref_addr_in
add wave -noupdate -group prefetcher /mp4_tb/dut/pref/pref_addr_load
add wave -noupdate -group prefetcher /mp4_tb/dut/pref/valid
add wave -noupdate -group prefetcher /mp4_tb/dut/pref/state
add wave -noupdate -group prefetcher /mp4_tb/dut/pref/next_state
add wave -noupdate /mp4_tb/num_inst
add wave -noupdate /mp4_tb/num_rob_full
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {9145608 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 452
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
WaveRestoreZoom {574298981 ps} {576505317 ps}
