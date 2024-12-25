# Legal Notice: (C)2024 Altera Corporation. All rights reserved.  Your
# use of Altera Corporation's design tools, logic functions and other
# software and tools, and its AMPP partner logic functions, and any
# output files any of the foregoing (including device programming or
# simulation files), and any associated documentation or information are
# expressly subject to the terms and conditions of the Altera Program
# License Subscription Agreement or other applicable license agreement,
# including, without limitation, that your use is for the sole purpose
# of programming logic devices manufactured by Altera and sold by Altera
# or its authorized distributors.  Please refer to the applicable
# agreement for further details.

#**************************************************************
# Timequest JTAG clock definition
#   Uncommenting the following lines will define the JTAG
#   clock in TimeQuest Timing Analyzer
#**************************************************************

#create_clock -period 10MHz {altera_internal_jtag|tckutap}
#set_clock_groups -asynchronous -group {altera_internal_jtag|tckutap}

#**************************************************************
# Set TCL Path Variables 
#**************************************************************

set 	NiosSoc_nios2cpu 	NiosSoc_nios2cpu:*
set 	NiosSoc_nios2cpu_oci 	NiosSoc_nios2cpu_nios2_oci:the_NiosSoc_nios2cpu_nios2_oci
set 	NiosSoc_nios2cpu_oci_break 	NiosSoc_nios2cpu_nios2_oci_break:the_NiosSoc_nios2cpu_nios2_oci_break
set 	NiosSoc_nios2cpu_ocimem 	NiosSoc_nios2cpu_nios2_ocimem:the_NiosSoc_nios2cpu_nios2_ocimem
set 	NiosSoc_nios2cpu_oci_debug 	NiosSoc_nios2cpu_nios2_oci_debug:the_NiosSoc_nios2cpu_nios2_oci_debug
set 	NiosSoc_nios2cpu_wrapper 	NiosSoc_nios2cpu_jtag_debug_module_wrapper:the_NiosSoc_nios2cpu_jtag_debug_module_wrapper
set 	NiosSoc_nios2cpu_jtag_tck 	NiosSoc_nios2cpu_jtag_debug_module_tck:the_NiosSoc_nios2cpu_jtag_debug_module_tck
set 	NiosSoc_nios2cpu_jtag_sysclk 	NiosSoc_nios2cpu_jtag_debug_module_sysclk:the_NiosSoc_nios2cpu_jtag_debug_module_sysclk
set 	NiosSoc_nios2cpu_oci_path 	 [format "%s|%s" $NiosSoc_nios2cpu $NiosSoc_nios2cpu_oci]
set 	NiosSoc_nios2cpu_oci_break_path 	 [format "%s|%s" $NiosSoc_nios2cpu_oci_path $NiosSoc_nios2cpu_oci_break]
set 	NiosSoc_nios2cpu_ocimem_path 	 [format "%s|%s" $NiosSoc_nios2cpu_oci_path $NiosSoc_nios2cpu_ocimem]
set 	NiosSoc_nios2cpu_oci_debug_path 	 [format "%s|%s" $NiosSoc_nios2cpu_oci_path $NiosSoc_nios2cpu_oci_debug]
set 	NiosSoc_nios2cpu_jtag_tck_path 	 [format "%s|%s|%s" $NiosSoc_nios2cpu_oci_path $NiosSoc_nios2cpu_wrapper $NiosSoc_nios2cpu_jtag_tck]
set 	NiosSoc_nios2cpu_jtag_sysclk_path 	 [format "%s|%s|%s" $NiosSoc_nios2cpu_oci_path $NiosSoc_nios2cpu_wrapper $NiosSoc_nios2cpu_jtag_sysclk]
set 	NiosSoc_nios2cpu_jtag_sr 	 [format "%s|*sr" $NiosSoc_nios2cpu_jtag_tck_path]

#**************************************************************
# Set False Paths
#**************************************************************

set_false_path -from [get_keepers *$NiosSoc_nios2cpu_oci_break_path|break_readreg*] -to [get_keepers *$NiosSoc_nios2cpu_jtag_sr*]
set_false_path -from [get_keepers *$NiosSoc_nios2cpu_oci_debug_path|*resetlatch]     -to [get_keepers *$NiosSoc_nios2cpu_jtag_sr[33]]
set_false_path -from [get_keepers *$NiosSoc_nios2cpu_oci_debug_path|monitor_ready]  -to [get_keepers *$NiosSoc_nios2cpu_jtag_sr[0]]
set_false_path -from [get_keepers *$NiosSoc_nios2cpu_oci_debug_path|monitor_error]  -to [get_keepers *$NiosSoc_nios2cpu_jtag_sr[34]]
set_false_path -from [get_keepers *$NiosSoc_nios2cpu_ocimem_path|*MonDReg*] -to [get_keepers *$NiosSoc_nios2cpu_jtag_sr*]
set_false_path -from *$NiosSoc_nios2cpu_jtag_sr*    -to *$NiosSoc_nios2cpu_jtag_sysclk_path|*jdo*
set_false_path -from sld_hub:*|irf_reg* -to *$NiosSoc_nios2cpu_jtag_sysclk_path|ir*
set_false_path -from sld_hub:*|sld_shadow_jsm:shadow_jsm|state[1] -to *$NiosSoc_nios2cpu_oci_debug_path|monitor_go
