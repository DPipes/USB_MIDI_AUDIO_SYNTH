# TCL File Generated by Component Editor 18.1
# Tue May 24 09:55:32 CDT 2022
# DO NOT MODIFY


# 
# wavetable_audio_synthesizer "Wavetable Audio Synthesizer" v1.0
# Dan Piper 2022.05.24.09:55:32
# This module uses wavetable synthesis to generate audio samples. It haswith full ADSR control and can play 128 notes simultaneously.
# 

# 
# request TCL package from ACDS 16.1
# 
package require -exact qsys 16.1


# 
# module wavetable_audio_synthesizer
# 
set_module_property DESCRIPTION "This module uses wavetable synthesis to generate audio samples. It haswith full ADSR control and can play 128 notes simultaneously."
set_module_property NAME wavetable_audio_synthesizer
set_module_property VERSION 1.0
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property GROUP "Personal IP"
set_module_property AUTHOR "Dan Piper"
set_module_property DISPLAY_NAME "Wavetable Audio Synthesizer"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property REPORT_TO_TALKBACK false
set_module_property ALLOW_GREYBOX_GENERATION false
set_module_property REPORT_HIERARCHY false


# 
# file sets
# 
add_fileset QUARTUS_SYNTH QUARTUS_SYNTH "" ""
set_fileset_property QUARTUS_SYNTH TOP_LEVEL synth_ip
set_fileset_property QUARTUS_SYNTH ENABLE_RELATIVE_INCLUDE_PATHS false
set_fileset_property QUARTUS_SYNTH ENABLE_FILE_OVERWRITE_MODE false
add_fileset_file synth_ip.sv SYSTEM_VERILOG PATH synth_ip.sv TOP_LEVEL_FILE
add_fileset_file datapath.sv SYSTEM_VERILOG PATH datapath.sv
add_fileset_file f_table.sv SYSTEM_VERILOG PATH f_table.sv
add_fileset_file saw_table.sv SYSTEM_VERILOG PATH saw_table.sv
add_fileset_file sine_table.sv SYSTEM_VERILOG PATH sine_table.sv
add_fileset_file square_table.sv SYSTEM_VERILOG PATH square_table.sv
add_fileset_file strange1_table.sv SYSTEM_VERILOG PATH strange1_table.sv
add_fileset_file strange2_table.sv SYSTEM_VERILOG PATH strange2_table.sv
add_fileset_file strange3_table.sv SYSTEM_VERILOG PATH strange3_table.sv
add_fileset_file strange4_table.sv SYSTEM_VERILOG PATH strange4_table.sv
add_fileset_file strange5_table.sv SYSTEM_VERILOG PATH strange5_table.sv
add_fileset_file test_wave_table.sv SYSTEM_VERILOG PATH test_wave_table.sv


# 
# parameters
# 


# 
# display items
# 


# 
# connection point CLK
# 
add_interface CLK clock end
set_interface_property CLK clockRate 100000000
set_interface_property CLK ENABLED true
set_interface_property CLK EXPORT_OF ""
set_interface_property CLK PORT_NAME_MAP ""
set_interface_property CLK CMSIS_SVD_VARIABLES ""
set_interface_property CLK SVD_ADDRESS_GROUP ""

add_interface_port CLK CLK clk Input 1


# 
# connection point RESET
# 
add_interface RESET reset end
set_interface_property RESET associatedClock CLK
set_interface_property RESET synchronousEdges DEASSERT
set_interface_property RESET ENABLED true
set_interface_property RESET EXPORT_OF ""
set_interface_property RESET PORT_NAME_MAP ""
set_interface_property RESET CMSIS_SVD_VARIABLES ""
set_interface_property RESET SVD_ADDRESS_GROUP ""

add_interface_port RESET RESET reset Input 1


# 
# connection point AVL_SLAVE
# 
add_interface AVL_SLAVE avalon end
set_interface_property AVL_SLAVE addressUnits WORDS
set_interface_property AVL_SLAVE associatedClock CLK
set_interface_property AVL_SLAVE associatedReset RESET
set_interface_property AVL_SLAVE bitsPerSymbol 8
set_interface_property AVL_SLAVE burstOnBurstBoundariesOnly false
set_interface_property AVL_SLAVE burstcountUnits WORDS
set_interface_property AVL_SLAVE explicitAddressSpan 0
set_interface_property AVL_SLAVE holdTime 0
set_interface_property AVL_SLAVE linewrapBursts false
set_interface_property AVL_SLAVE maximumPendingReadTransactions 0
set_interface_property AVL_SLAVE maximumPendingWriteTransactions 0
set_interface_property AVL_SLAVE readLatency 0
set_interface_property AVL_SLAVE readWaitTime 1
set_interface_property AVL_SLAVE setupTime 0
set_interface_property AVL_SLAVE timingUnits Cycles
set_interface_property AVL_SLAVE writeWaitTime 0
set_interface_property AVL_SLAVE ENABLED true
set_interface_property AVL_SLAVE EXPORT_OF ""
set_interface_property AVL_SLAVE PORT_NAME_MAP ""
set_interface_property AVL_SLAVE CMSIS_SVD_VARIABLES ""
set_interface_property AVL_SLAVE SVD_ADDRESS_GROUP ""

add_interface_port AVL_SLAVE AVL_ADDR address Input 8
add_interface_port AVL_SLAVE AVL_READ read Input 1
add_interface_port AVL_SLAVE AVL_READDATA readdata Output 32
add_interface_port AVL_SLAVE AVL_WRITE write Input 1
add_interface_port AVL_SLAVE AVL_WRITEDATA writedata Input 32
set_interface_assignment AVL_SLAVE embeddedsw.configuration.isFlash 0
set_interface_assignment AVL_SLAVE embeddedsw.configuration.isMemoryDevice 0
set_interface_assignment AVL_SLAVE embeddedsw.configuration.isNonVolatileStorage 0
set_interface_assignment AVL_SLAVE embeddedsw.configuration.isPrintableDevice 0


# 
# connection point SYNTH_PORT
# 
add_interface SYNTH_PORT conduit end
set_interface_property SYNTH_PORT associatedClock CLK
set_interface_property SYNTH_PORT associatedReset ""
set_interface_property SYNTH_PORT ENABLED true
set_interface_property SYNTH_PORT EXPORT_OF ""
set_interface_property SYNTH_PORT PORT_NAME_MAP ""
set_interface_property SYNTH_PORT CMSIS_SVD_VARIABLES ""
set_interface_property SYNTH_PORT SVD_ADDRESS_GROUP ""

add_interface_port SYNTH_PORT RUN run Input 1
add_interface_port SYNTH_PORT FIFO_FULL fifo_full Input 1
add_interface_port SYNTH_PORT LD_FIFO ld_fifo Output 1
add_interface_port SYNTH_PORT TONE tone Output 32

