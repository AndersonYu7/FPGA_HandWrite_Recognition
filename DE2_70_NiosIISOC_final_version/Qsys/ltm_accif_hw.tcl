# TCL File Generated by Component Editor 13.0sp1
# Sun Nov 14 11:58:31 CST 2021
# DO NOT MODIFY


# 
# ltm_mm "ltm_mm" v1.0
#  2021.11.14.11:58:31
# 
# 

# 
# request TCL package from ACDS 13.1
# 
package require -exact qsys 13.1


# 
# module ltm_mm
# 
set_module_property DESCRIPTION ""
set_module_property NAME ltm_mm
set_module_property VERSION 1.0
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property AUTHOR ""
set_module_property DISPLAY_NAME ltm_mm
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ANALYZE_HDL AUTO
set_module_property REPORT_TO_TALKBACK false
set_module_property ALLOW_GREYBOX_GENERATION false


# 
# file sets
# 
add_fileset QUARTUS_SYNTH QUARTUS_SYNTH "" ""
set_fileset_property QUARTUS_SYNTH TOP_LEVEL LTM_MM_if
set_fileset_property QUARTUS_SYNTH ENABLE_RELATIVE_INCLUDE_PATHS false
add_fileset_file LTM_Master_Controller.v VERILOG PATH ../ip/LTM_MM/LTM_Master_Controller.v
add_fileset_file LTM_MM_if.v VERILOG PATH ../ip/LTM_MM/LTM_MM_if.v TOP_LEVEL_FILE
add_fileset_file UDCFIFO.v VERILOG PATH ../ip/LTM_MM/UDCFIFO.v


# 
# parameters
# 
add_parameter LTM_ADDRESS STD_LOGIC_VECTOR 134217728
set_parameter_property LTM_ADDRESS DEFAULT_VALUE 134217728
set_parameter_property LTM_ADDRESS DISPLAY_NAME LTM_ADDRESS
set_parameter_property LTM_ADDRESS TYPE STD_LOGIC_VECTOR
set_parameter_property LTM_ADDRESS UNITS None
set_parameter_property LTM_ADDRESS ALLOWED_RANGES 0:17179869183
set_parameter_property LTM_ADDRESS HDL_PARAMETER true


# 
# display items
# 


# 
# connection point clockreset
# 
add_interface clockreset clock end
set_interface_property clockreset clockRate 0
set_interface_property clockreset ENABLED true
set_interface_property clockreset EXPORT_OF ""
set_interface_property clockreset PORT_NAME_MAP ""
set_interface_property clockreset SVD_ADDRESS_GROUP ""

add_interface_port clockreset csi_clockreset_clk clk Input 1


# 
# connection point clockreset_reset
# 
add_interface clockreset_reset reset end
set_interface_property clockreset_reset associatedClock clockreset
set_interface_property clockreset_reset synchronousEdges DEASSERT
set_interface_property clockreset_reset ENABLED true
set_interface_property clockreset_reset EXPORT_OF ""
set_interface_property clockreset_reset PORT_NAME_MAP ""
set_interface_property clockreset_reset SVD_ADDRESS_GROUP ""

add_interface_port clockreset_reset csi_clockreset_reset_n reset_n Input 1


# 
# connection point m1
# 
add_interface m1 avalon start
set_interface_property m1 addressUnits SYMBOLS
set_interface_property m1 associatedClock clockreset
set_interface_property m1 associatedReset clockreset_reset
set_interface_property m1 bitsPerSymbol 8
set_interface_property m1 burstOnBurstBoundariesOnly false
set_interface_property m1 burstcountUnits WORDS
set_interface_property m1 doStreamReads false
set_interface_property m1 doStreamWrites false
set_interface_property m1 holdTime 0
set_interface_property m1 linewrapBursts false
set_interface_property m1 maximumPendingReadTransactions 0
set_interface_property m1 readLatency 0
set_interface_property m1 readWaitTime 1
set_interface_property m1 setupTime 0
set_interface_property m1 timingUnits Cycles
set_interface_property m1 writeWaitTime 0
set_interface_property m1 ENABLED true
set_interface_property m1 EXPORT_OF ""
set_interface_property m1 PORT_NAME_MAP ""
set_interface_property m1 SVD_ADDRESS_GROUP ""

add_interface_port m1 avm_m1_address address Output 32
add_interface_port m1 avm_m1_burstcount burstcount Output 10
add_interface_port m1 avm_m1_byteenable byteenable Output 4
add_interface_port m1 avm_m1_waitrequest waitrequest Input 1
add_interface_port m1 avm_m1_read read Output 1
add_interface_port m1 avm_m1_flush flush Output 1
add_interface_port m1 avm_m1_readdatavalid readdatavalid Input 1
add_interface_port m1 avm_m1_readdata readdata Input 32


# 
# connection point s1
# 
add_interface s1 avalon end
set_interface_property s1 addressUnits WORDS
set_interface_property s1 associatedClock clockreset
set_interface_property s1 associatedReset clockreset_reset
set_interface_property s1 bitsPerSymbol 8
set_interface_property s1 burstOnBurstBoundariesOnly false
set_interface_property s1 burstcountUnits WORDS
set_interface_property s1 explicitAddressSpan 0
set_interface_property s1 holdTime 0
set_interface_property s1 linewrapBursts false
set_interface_property s1 maximumPendingReadTransactions 0
set_interface_property s1 readLatency 2
set_interface_property s1 readWaitTime 1
set_interface_property s1 setupTime 0
set_interface_property s1 timingUnits Cycles
set_interface_property s1 writeWaitTime 0
set_interface_property s1 ENABLED true
set_interface_property s1 EXPORT_OF ""
set_interface_property s1 PORT_NAME_MAP ""
set_interface_property s1 SVD_ADDRESS_GROUP ""

add_interface_port s1 avs_s1_write write Input 1
add_interface_port s1 avs_s1_writedata writedata Input 32
add_interface_port s1 avs_s1_read read Input 1
add_interface_port s1 avs_s1_readdata readdata Output 32
add_interface_port s1 avs_s1_address address Input 4
add_interface_port s1 avs_s1_waitrequest_n waitrequest_n Output 1
add_interface_port s1 avs_s1_byteenable byteenable Input 4
set_interface_assignment s1 embeddedsw.configuration.isFlash 0
set_interface_assignment s1 embeddedsw.configuration.isMemoryDevice 0
set_interface_assignment s1 embeddedsw.configuration.isNonVolatileStorage 0
set_interface_assignment s1 embeddedsw.configuration.isPrintableDevice 0


# 
# connection point export_m1
# 
add_interface export_m1 conduit end
set_interface_property export_m1 associatedClock clockreset
set_interface_property export_m1 associatedReset ""
set_interface_property export_m1 ENABLED true
set_interface_property export_m1 EXPORT_OF ""
set_interface_property export_m1 PORT_NAME_MAP ""
set_interface_property export_m1 SVD_ADDRESS_GROUP ""

add_interface_port export_m1 avm_m1_export_iVD export Input 1
add_interface_port export_m1 avm_m1_export_iRDCLK export Input 1
add_interface_port export_m1 avm_m1_export_iRDREQ export Input 1
add_interface_port export_m1 avm_m1_export_oRDDATA export Output 32
add_interface_port export_m1 avm_m1_export_oRDVal export Output 1
add_interface_port export_m1 avm_m1_export_oPixelX export Output 10
add_interface_port export_m1 avm_m1_export_oPixelY export Output 10
add_interface_port export_m1 avm_m1_export_oFIFO_FULL export Output 1
add_interface_port export_m1 avm_m1_export_oFIFO_EMPTY export Output 1

