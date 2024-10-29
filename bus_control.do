onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /bus_control_tb/CLK
add wave -noupdate /bus_control_tb/nRST
add wave -noupdate /bus_control_tb/tb_test_num
add wave -noupdate /bus_control_tb/tb_test_case
add wave -noupdate /bus_control_tb/DUT/state
add wave -noupdate /bus_control_tb/DUT/next_state
add wave -noupdate /bus_control_tb/DUT/core
add wave -noupdate /bus_control_tb/DUT/lru
add wave -noupdate /bus_control_tb/DUT/cc/iREN
add wave -noupdate /bus_control_tb/DUT/cc/iwait
add wave -noupdate /bus_control_tb/DUT/cc/iload
add wave -noupdate /bus_control_tb/DUT/cc/iaddr
add wave -noupdate /bus_control_tb/DUT/cc/dWEN
add wave -noupdate /bus_control_tb/DUT/cc/dwait
add wave -noupdate /bus_control_tb/DUT/cc/dstore
add wave -noupdate /bus_control_tb/DUT/cc/dREN
add wave -noupdate /bus_control_tb/DUT/cc/dload
add wave -noupdate /bus_control_tb/DUT/cc/daddr
add wave -noupdate /bus_control_tb/DUT/cc/ccwrite
add wave -noupdate /bus_control_tb/DUT/cc/ccwait
add wave -noupdate /bus_control_tb/DUT/cc/cctrans
add wave -noupdate /bus_control_tb/DUT/cc/ccsnoopaddr
add wave -noupdate /bus_control_tb/DUT/cc/ccinv
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {21 ns} 0}
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
WaveRestoreZoom {0 ns} {95 ns}
