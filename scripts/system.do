onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /system_tb/CLK
add wave -noupdate /system_tb/nRST
add wave -noupdate /system_tb/CLK
add wave -noupdate /system_tb/nRST
add wave -noupdate /system_tb/CLK
add wave -noupdate /system_tb/nRST
add wave -noupdate /system_tb/CLK
add wave -noupdate /system_tb/nRST
add wave -noupdate /system_tb/nRST
add wave -noupdate /system_tb/nRST
add wave -noupdate /system_tb/DUT/CPU/ccif/iaddr
add wave -noupdate /system_tb/DUT/CPU/DP/ru/dhit
add wave -noupdate /system_tb/CLK
add wave -noupdate /system_tb/DUT/CPU/CLK
add wave -noupdate /system_tb/DUT/CPU/DP/ru/ihit
add wave -noupdate /system_tb/DUT/CPU/DP/cif/instruction
add wave -noupdate /system_tb/DUT/CPU/DP/dpif/imemload
add wave -noupdate /system_tb/DUT/CPU/DP/dpif/dmemload
add wave -noupdate /system_tb/DUT/CPU/DP/dpif/dmemstore
add wave -noupdate /system_tb/DUT/CPU/DP/dpif/dmemaddr
add wave -noupdate /system_tb/DUT/CPU/DP/ru/imemREN
add wave -noupdate -radix decimal /system_tb/DUT/CPU/DP/prog/pc
add wave -noupdate -radix decimal /system_tb/DUT/CPU/DP/pc/next_pc
add wave -noupdate -radix decimal /system_tb/DUT/CPU/DP/dpif/imemaddr
add wave -noupdate /system_tb/DUT/CPU/DP/ru/dhit
add wave -noupdate /system_tb/DUT/CPU/DP/ru/dmemREN
add wave -noupdate /system_tb/DUT/CPU/DP/ru/dmemWEN
add wave -noupdate /system_tb/DUT/CPU/DP/ru/memwrite
add wave -noupdate /system_tb/DUT/CPU/DP/ru/memread
add wave -noupdate /system_tb/DUT/CPU/DP/ru/pc_enable
add wave -noupdate -radix hexadecimal /system_tb/DUT/CPU/DP/aluif/result
add wave -noupdate -radix decimal /system_tb/DUT/CPU/DP/cif/imm_gen
add wave -noupdate /system_tb/DUT/CPU/DP/rfif/rsel1
add wave -noupdate /system_tb/DUT/CPU/DP/rfif/rsel2
add wave -noupdate /system_tb/DUT/CPU/DP/rfif/rdat1
add wave -noupdate /system_tb/DUT/CPU/DP/rfif/rdat2
add wave -noupdate /system_tb/DUT/CPU/DP/bif/branch_type
add wave -noupdate /system_tb/DUT/CPU/DP/rf/registers
add wave -noupdate /system_tb/DUT/CPU/DP/rfif/wsel
add wave -noupdate /system_tb/DUT/prif/ramaddr
add wave -noupdate /system_tb/DUT/prif/ramstore
add wave -noupdate /system_tb/DUT/prif/ramWEN
add wave -noupdate -radix hexadecimal /system_tb/DUT/prif/ramload
add wave -noupdate /system_tb/DUT/prif/ramstate
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {853544 ps} 0}
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
WaveRestoreZoom {607679 ps} {923679 ps}
