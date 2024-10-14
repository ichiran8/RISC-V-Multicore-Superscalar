onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /icache_tb/CLK
add wave -noupdate /icache_tb/nRST
add wave -noupdate /icache_tb/CPUCLK
add wave -noupdate /icache_tb/count
add wave -noupdate /icache_tb/i
add wave -noupdate /icache_tb/tb_test_num
add wave -noupdate /icache_tb/expected_out
add wave -noupdate /icache_tb/DUT/state
add wave -noupdate /icache_tb/DUT/next_state
add wave -noupdate /icache_tb/cif0/iREN
add wave -noupdate /icache_tb/DUT/next_iREN
add wave -noupdate /icache_tb/DUT/next_iaddr
add wave -noupdate /icache_tb/DUT/next_cache
add wave -noupdate /icache_tb/DUT/imiss
add wave -noupdate /icache_tb/DUT/icheck
add wave -noupdate /icache_tb/DUT/cache
add wave -noupdate /icache_tb/dpif/imemaddr
add wave -noupdate /icache_tb/dpif/imemload
add wave -noupdate /icache_tb/dpif/ihit
add wave -noupdate /icache_tb/cif0/iwait
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {159726 ps} 0}
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
WaveRestoreZoom {0 ps} {283840 ps}
