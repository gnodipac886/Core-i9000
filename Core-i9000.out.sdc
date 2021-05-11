## Generated SDC file "Core-i9000.out.sdc"

## Copyright (C) 2018  Intel Corporation. All rights reserved.
## Your use of Intel Corporation's design tools, logic functions 
## and other software and tools, and its AMPP partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Intel Program License 
## Subscription Agreement, the Intel Quartus Prime License Agreement,
## the Intel FPGA IP License Agreement, or other applicable license
## agreement, including, without limitation, that your use is for
## the sole purpose of programming logic devices manufactured by
## Intel and sold by Intel or its authorized distributors.  Please
## refer to the applicable agreement for further details.


## VENDOR  "Altera"
## PROGRAM "Quartus Prime"
## VERSION "Version 18.1.0 Build 625 09/12/2018 SJ Standard Edition"

## DATE    "Mon May 10 14:13:33 2021"

##
## DEVICE  "EP2AGX260FF35I3"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {clk} -period 10.000 -waveform { 0.000 5.000 } [get_ports {clk}]


#**************************************************************
# Create Generated Clock
#**************************************************************



#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************

set_clock_uncertainty -rise_from [get_clocks {clk}] -rise_to [get_clocks {clk}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {clk}] -fall_to [get_clocks {clk}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {clk}] -rise_to [get_clocks {clk}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {clk}] -fall_to [get_clocks {clk}]  0.020  


#**************************************************************
# Set Input Delay
#**************************************************************

set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {clk}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_rdata[0]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_rdata[1]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_rdata[2]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_rdata[3]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_rdata[4]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_rdata[5]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_rdata[6]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_rdata[7]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_rdata[8]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_rdata[9]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_rdata[10]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_rdata[11]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_rdata[12]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_rdata[13]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_rdata[14]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_rdata[15]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_rdata[16]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_rdata[17]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_rdata[18]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_rdata[19]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_rdata[20]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_rdata[21]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_rdata[22]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_rdata[23]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_rdata[24]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_rdata[25]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_rdata[26]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_rdata[27]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_rdata[28]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_rdata[29]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_rdata[30]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_rdata[31]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_rdata[32]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_rdata[33]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_rdata[34]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_rdata[35]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_rdata[36]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_rdata[37]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_rdata[38]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_rdata[39]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_rdata[40]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_rdata[41]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_rdata[42]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_rdata[43]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_rdata[44]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_rdata[45]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_rdata[46]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_rdata[47]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_rdata[48]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_rdata[49]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_rdata[50]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_rdata[51]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_rdata[52]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_rdata[53]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_rdata[54]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_rdata[55]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_rdata[56]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_rdata[57]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_rdata[58]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_rdata[59]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_rdata[60]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_rdata[61]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_rdata[62]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_rdata[63]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_resp}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {rst}]


#**************************************************************
# Set Output Delay
#**************************************************************

set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_address[0]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_address[1]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_address[2]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_address[3]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_address[4]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_address[5]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_address[6]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_address[7]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_address[8]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_address[9]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_address[10]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_address[11]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_address[12]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_address[13]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_address[14]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_address[15]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_address[16]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_address[17]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_address[18]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_address[19]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_address[20]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_address[21]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_address[22]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_address[23]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_address[24]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_address[25]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_address[26]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_address[27]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_address[28]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_address[29]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_address[30]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_address[31]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_read}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_wdata[0]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_wdata[1]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_wdata[2]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_wdata[3]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_wdata[4]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_wdata[5]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_wdata[6]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_wdata[7]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_wdata[8]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_wdata[9]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_wdata[10]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_wdata[11]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_wdata[12]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_wdata[13]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_wdata[14]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_wdata[15]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_wdata[16]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_wdata[17]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_wdata[18]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_wdata[19]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_wdata[20]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_wdata[21]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_wdata[22]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_wdata[23]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_wdata[24]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_wdata[25]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_wdata[26]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_wdata[27]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_wdata[28]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_wdata[29]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_wdata[30]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_wdata[31]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_wdata[32]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_wdata[33]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_wdata[34]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_wdata[35]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_wdata[36]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_wdata[37]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_wdata[38]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_wdata[39]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_wdata[40]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_wdata[41]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_wdata[42]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_wdata[43]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_wdata[44]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_wdata[45]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_wdata[46]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_wdata[47]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_wdata[48]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_wdata[49]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_wdata[50]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_wdata[51]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_wdata[52]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_wdata[53]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_wdata[54]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_wdata[55]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_wdata[56]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_wdata[57]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_wdata[58]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_wdata[59]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_wdata[60]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_wdata[61]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_wdata[62]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_wdata[63]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pmem_write}]


#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************



#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************

