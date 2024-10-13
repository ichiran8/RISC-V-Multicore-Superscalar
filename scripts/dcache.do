onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -color Gold -radix decimal /dcache_tb/tb_test_num
add wave -noupdate -color Gold /dcache_tb/tb_test_case
add wave -noupdate /dcache_tb/CPUCLK
add wave -noupdate /dcache_tb/CLK
add wave -noupdate /dcache_tb/nRST
add wave -noupdate -divider DUT
add wave -noupdate -expand -group DCACHE /dcache_tb/DUT/req
add wave -noupdate -expand -group DCACHE /dcache_tb/DUT/frame_select
add wave -noupdate -expand -group DCACHE /dcache_tb/DUT/frame
add wave -noupdate -expand -group DCACHE -subitemconfig {{/dcache_tb/DUT/next_frame[1]} -expand {/dcache_tb/DUT/next_frame[1][0]} -expand} /dcache_tb/DUT/next_frame
add wave -noupdate -expand -group DCACHE /dcache_tb/DUT/lru
add wave -noupdate -expand -group DCACHE /dcache_tb/DUT/next_lru
add wave -noupdate -expand -group DCACHE -radix decimal /dcache_tb/DUT/hit_counter
add wave -noupdate -expand -group DCACHE -radix decimal /dcache_tb/DUT/next_hit_counter
add wave -noupdate -expand -group DCACHE /dcache_tb/DUT/state
add wave -noupdate -expand -group DCACHE /dcache_tb/DUT/next_state
add wave -noupdate -expand -group {DATAPATH SIGNALS} /dcache_tb/DUT/dpif/halt
add wave -noupdate -expand -group {DATAPATH SIGNALS} /dcache_tb/DUT/dpif/dhit
add wave -noupdate -expand -group {DATAPATH SIGNALS} /dcache_tb/DUT/dpif/dmemREN
add wave -noupdate -expand -group {DATAPATH SIGNALS} /dcache_tb/DUT/dpif/dmemWEN
add wave -noupdate -expand -group {DATAPATH SIGNALS} /dcache_tb/DUT/dpif/flushed
add wave -noupdate -expand -group {DATAPATH SIGNALS} /dcache_tb/DUT/dpif/dmemload
add wave -noupdate -expand -group {DATAPATH SIGNALS} /dcache_tb/DUT/dpif/dmemstore
add wave -noupdate -expand -group {DATAPATH SIGNALS} /dcache_tb/DUT/dpif/dmemaddr
add wave -noupdate -expand -group {DATAPATH SIGNALS} /dcache_tb/DUT/dpif/datomic
add wave -noupdate -group {CONTROLLER SIGNALS} /dcache_tb/DUT/ccif/dwait
add wave -noupdate -group {CONTROLLER SIGNALS} /dcache_tb/DUT/ccif/dREN
add wave -noupdate -group {CONTROLLER SIGNALS} /dcache_tb/DUT/ccif/dWEN
add wave -noupdate -group {CONTROLLER SIGNALS} /dcache_tb/DUT/ccif/dload
add wave -noupdate -group {CONTROLLER SIGNALS} /dcache_tb/DUT/ccif/dstore
add wave -noupdate -group {CONTROLLER SIGNALS} /dcache_tb/DUT/ccif/daddr
add wave -noupdate -group {CONTROLLER SIGNALS} /dcache_tb/mc_cache_if/ramWEN
add wave -noupdate -group {CONTROLLER SIGNALS} /dcache_tb/mc_cache_if/ramREN
add wave -noupdate -group {CONTROLLER SIGNALS} /dcache_tb/mc_cache_if/ramstate
add wave -noupdate -group {CONTROLLER SIGNALS} /dcache_tb/mc_cache_if/ramaddr
add wave -noupdate -group {CONTROLLER SIGNALS} /dcache_tb/mc_cache_if/ramstore
add wave -noupdate -group {CONTROLLER SIGNALS} /dcache_tb/mc_cache_if/ramload
add wave -noupdate -group {CONTROLLER SIGNALS} /dcache_tb/DUT/ccif/ccwait
add wave -noupdate -group {CONTROLLER SIGNALS} /dcache_tb/DUT/ccif/ccinv
add wave -noupdate -group {CONTROLLER SIGNALS} /dcache_tb/DUT/ccif/ccwrite
add wave -noupdate -group {CONTROLLER SIGNALS} /dcache_tb/DUT/ccif/cctrans
add wave -noupdate -group {CONTROLLER SIGNALS} /dcache_tb/DUT/ccif/ccsnoopaddr
add wave -noupdate -group RAM /dcache_tb/RAM/CLK
add wave -noupdate -group RAM /dcache_tb/RAM/nRST
add wave -noupdate -group RAM /dcache_tb/RAM/count
add wave -noupdate -group RAM /dcache_tb/RAM/rstate
add wave -noupdate -group RAM /dcache_tb/RAM/q
add wave -noupdate -group RAM /dcache_tb/RAM/addr
add wave -noupdate -group RAM /dcache_tb/RAM/wren
add wave -noupdate -group RAM /dcache_tb/RAM/en
add wave -noupdate -group ramif /dcache_tb/RAM/ramif/ramREN
add wave -noupdate -group ramif /dcache_tb/RAM/ramif/ramWEN
add wave -noupdate -group ramif /dcache_tb/RAM/ramif/ramaddr
add wave -noupdate -group ramif /dcache_tb/RAM/ramif/ramstore
add wave -noupdate -group ramif /dcache_tb/RAM/ramif/ramload
add wave -noupdate -group ramif /dcache_tb/RAM/ramif/ramstate
add wave -noupdate -group ramif /dcache_tb/RAM/ramif/memREN
add wave -noupdate -group ramif /dcache_tb/RAM/ramif/memWEN
add wave -noupdate -group ramif /dcache_tb/RAM/ramif/memaddr
add wave -noupdate -group ramif /dcache_tb/RAM/ramif/memstore
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {113912 ps} 0}
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
WaveRestoreZoom {55263 ps} {165513 ps}
