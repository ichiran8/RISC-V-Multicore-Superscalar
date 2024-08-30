onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /memory_control_tb/CLK
add wave -noupdate /memory_control_tb/nRST
add wave -noupdate /memory_control_tb/i
add wave -noupdate /memory_control_tb/CPUCLK
add wave -noupdate /memory_control_tb/count
add wave -noupdate /memory_control_tb/CLK
add wave -noupdate /memory_control_tb/nRST
add wave -noupdate /memory_control_tb/i
add wave -noupdate /memory_control_tb/DUTRAM/BAD
add wave -noupdate /memory_control_tb/DUTRAM/LAT
add wave -noupdate /memory_control_tb/DUTRAM/CLK
add wave -noupdate /memory_control_tb/DUTRAM/nRST
add wave -noupdate /memory_control_tb/DUTRAM/count
add wave -noupdate /memory_control_tb/DUTRAM/rstate
add wave -noupdate /memory_control_tb/DUTRAM/q
add wave -noupdate /memory_control_tb/DUTRAM/addr
add wave -noupdate /memory_control_tb/DUTRAM/wren
add wave -noupdate /memory_control_tb/DUTRAM/en
add wave -noupdate /memory_control_tb/DUTRAM/ramif/ramREN
add wave -noupdate /memory_control_tb/DUTRAM/ramif/ramWEN
add wave -noupdate /memory_control_tb/DUTRAM/ramif/ramaddr
add wave -noupdate /memory_control_tb/DUTRAM/ramif/ramstore
add wave -noupdate /memory_control_tb/DUTRAM/ramif/ramload
add wave -noupdate /memory_control_tb/DUTRAM/ramif/ramstate
add wave -noupdate /memory_control_tb/DUTRAM/ramif/memREN
add wave -noupdate /memory_control_tb/DUTRAM/ramif/memWEN
add wave -noupdate /memory_control_tb/DUTRAM/ramif/memaddr
add wave -noupdate /memory_control_tb/DUTRAM/ramif/memstore
add wave -noupdate /memory_control_tb/ccif/cif0/dwait
add wave -noupdate /memory_control_tb/ccif/cif0/iREN
add wave -noupdate /memory_control_tb/ccif/cif0/dREN
add wave -noupdate /memory_control_tb/ccif/cif0/dWEN
add wave -noupdate /memory_control_tb/ccif/cif0/iload
add wave -noupdate /memory_control_tb/ccif/cif0/dload
add wave -noupdate /memory_control_tb/ccif/cif0/dstore
add wave -noupdate /memory_control_tb/ccif/cif0/iaddr
add wave -noupdate /memory_control_tb/ccif/cif0/daddr
add wave -noupdate /memory_control_tb/ccif/cif0/ccwait
add wave -noupdate /memory_control_tb/ccif/cif0/ccinv
add wave -noupdate /memory_control_tb/ccif/cif0/ccwrite
add wave -noupdate /memory_control_tb/ccif/cif0/cctrans
add wave -noupdate /memory_control_tb/ccif/cif0/ccsnoopaddr
add wave -noupdate /memory_control_tb/cif0/dWEN
add wave -noupdate /memory_control_tb/cif0/dREN
add wave -noupdate /memory_control_tb/cif0/iREN
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {964589 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
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
WaveRestoreZoom {422400 ps} {1030400 ps}
