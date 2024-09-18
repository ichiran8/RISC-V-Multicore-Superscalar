onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -color Gold /forwarding_unit_tb/tb_test_num
add wave -noupdate -color Gold /forwarding_unit_tb/tb_test_case
add wave -noupdate -divider DUT
add wave -noupdate /forwarding_unit_tb/id_ex_rsel1
add wave -noupdate /forwarding_unit_tb/id_ex_rsel2
add wave -noupdate /forwarding_unit_tb/ex_mem_wsel
add wave -noupdate /forwarding_unit_tb/mem_wb_wsel
add wave -noupdate /forwarding_unit_tb/ex_mem_regwrite
add wave -noupdate /forwarding_unit_tb/mem_wb_regwrite
add wave -noupdate /forwarding_unit_tb/forwardA
add wave -noupdate /forwarding_unit_tb/forwardB
add wave -noupdate /forwarding_unit_tb/expected_forwardA
add wave -noupdate /forwarding_unit_tb/expected_forwardB
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {3 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 103
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
WaveRestoreZoom {0 ns} {21 ns}
