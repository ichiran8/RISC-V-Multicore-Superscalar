onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /system_tb/DUT/CPUCLK
add wave -noupdate /system_tb/DUT/nRST
add wave -noupdate /system_tb/DUT/CLK
add wave -noupdate /system_tb/DUT/halt
add wave -noupdate -divider Datapath
add wave -noupdate /system_tb/DUT/CPU/DP0/rf/registers
add wave -noupdate -expand -group {CORE 0} /system_tb/DUT/CPU/DP0/PC_INIT
add wave -noupdate -expand -group {CORE 0} /system_tb/DUT/CPU/DP0/CLK
add wave -noupdate -expand -group {CORE 0} /system_tb/DUT/CPU/DP0/nRST
add wave -noupdate -expand -group {CORE 0} /system_tb/DUT/CPU/DP0/next_pc
add wave -noupdate -expand -group {CORE 0} /system_tb/DUT/CPU/DP0/pc
add wave -noupdate -expand -group {CORE 0} /system_tb/DUT/CPU/DP0/portA1
add wave -noupdate -expand -group {CORE 0} /system_tb/DUT/CPU/DP0/portB1
add wave -noupdate -expand -group {CORE 0} /system_tb/DUT/CPU/DP0/portA2
add wave -noupdate -expand -group {CORE 0} /system_tb/DUT/CPU/DP0/portB2
add wave -noupdate -expand -group {CORE 0} /system_tb/DUT/CPU/DP0/control_pipe
add wave -noupdate -expand -group {CORE 0} /system_tb/DUT/CPU/DP0/stall_flag
add wave -noupdate -expand -group {CORE 0} /system_tb/DUT/CPU/DP0/stall_check
add wave -noupdate -expand -group {CORE 0} /system_tb/DUT/CPU/DP0/PCWrite
add wave -noupdate -expand -group {CORE 0} /system_tb/DUT/CPU/DP0/if_id_write1
add wave -noupdate -expand -group {CORE 0} /system_tb/DUT/CPU/DP0/if_id_write2
add wave -noupdate -expand -group {CORE 0} /system_tb/DUT/CPU/DP0/if_flush
add wave -noupdate -expand -group {CORE 0} /system_tb/DUT/CPU/DP0/id_flush1
add wave -noupdate -expand -group {CORE 0} /system_tb/DUT/CPU/DP0/id_flush2
add wave -noupdate -expand -group {CORE 0} /system_tb/DUT/CPU/DP0/branch1
add wave -noupdate -expand -group {CORE 0} /system_tb/DUT/CPU/DP0/branch2
add wave -noupdate -expand -group {CORE 0} /system_tb/DUT/CPU/DP0/forwardA1
add wave -noupdate -expand -group {CORE 0} /system_tb/DUT/CPU/DP0/forwardB1
add wave -noupdate -expand -group {CORE 0} /system_tb/DUT/CPU/DP0/forwardA2
add wave -noupdate -expand -group {CORE 0} /system_tb/DUT/CPU/DP0/forwardB2
add wave -noupdate -expand -group {CORE 0} /system_tb/DUT/CPU/DP0/if_id1
add wave -noupdate -expand -group {CORE 0} /system_tb/DUT/CPU/DP0/if_id2
add wave -noupdate -expand -group {CORE 0} /system_tb/DUT/CPU/DP0/id_ex1
add wave -noupdate -expand -group {CORE 0} /system_tb/DUT/CPU/DP0/id_ex2
add wave -noupdate -expand -group {CORE 0} -expand /system_tb/DUT/CPU/DP0/ex_mem1
add wave -noupdate -expand -group {CORE 0} -expand /system_tb/DUT/CPU/DP0/ex_mem2
add wave -noupdate -expand -group {CORE 0} /system_tb/DUT/CPU/DP0/mem_wb1
add wave -noupdate -expand -group {CORE 0} /system_tb/DUT/CPU/DP0/mem_wb2
add wave -noupdate -expand -group {CORE 0} /system_tb/DUT/CPU/DP0/stall
add wave -noupdate -expand -group {CORE 0} /system_tb/DUT/CPU/DP0/mem_dep
add wave -noupdate -expand -group {CORE 0} /system_tb/DUT/CPU/DP0/write_selected1
add wave -noupdate -expand -group {CORE 0} /system_tb/DUT/CPU/DP0/write_selected2
add wave -noupdate -expand -group {CORE 0} /system_tb/DUT/CPU/DP0/load1
add wave -noupdate -expand -group {CORE 0} /system_tb/DUT/CPU/DP0/load2
add wave -noupdate -expand -group {CORE 0} -expand -group ICACHE0 /system_tb/DUT/CPU/CM0/ICACHE/CLK
add wave -noupdate -expand -group {CORE 0} -expand -group ICACHE0 /system_tb/DUT/CPU/CM0/ICACHE/nRST
add wave -noupdate -expand -group {CORE 0} -expand -group ICACHE0 -expand -subitemconfig {{/system_tb/DUT/CPU/CM0/ICACHE/cache[15]} -expand {/system_tb/DUT/CPU/CM0/ICACHE/cache[15].data} -expand} /system_tb/DUT/CPU/CM0/ICACHE/cache
add wave -noupdate -expand -group {CORE 0} -expand -group ICACHE0 /system_tb/DUT/CPU/CM0/ICACHE/next_cache
add wave -noupdate -expand -group {CORE 0} -expand -group ICACHE0 /system_tb/DUT/CPU/CM0/ICACHE/state
add wave -noupdate -expand -group {CORE 0} -expand -group ICACHE0 /system_tb/DUT/CPU/CM0/ICACHE/next_state
add wave -noupdate -expand -group {CORE 0} -expand -group ICACHE0 -expand /system_tb/DUT/CPU/CM0/ICACHE/instr1
add wave -noupdate -expand -group {CORE 0} -expand -group ICACHE0 -expand -subitemconfig {/system_tb/DUT/CPU/CM0/ICACHE/instr2.tag -expand /system_tb/DUT/CPU/CM0/ICACHE/instr2.idx -expand /system_tb/DUT/CPU/CM0/ICACHE/instr2.bytoff -expand} /system_tb/DUT/CPU/CM0/ICACHE/instr2
add wave -noupdate -expand -group {CORE 0} -expand -group ICACHE0 /system_tb/DUT/CPU/CM0/ICACHE/next_iREN
add wave -noupdate -expand -group {CORE 0} -expand -group ICACHE0 /system_tb/DUT/CPU/CM0/ICACHE/next_iaddr
add wave -noupdate -expand -group {CORE 0} -expand -group ICACHE0 /system_tb/DUT/CPU/CM0/ICACHE/ihit1
add wave -noupdate -expand -group {CORE 0} -expand -group ICACHE0 /system_tb/DUT/CPU/CM0/ICACHE/ihit2
add wave -noupdate -expand -group {CORE 0} -group {DCACHE 0} /system_tb/DUT/CPU/CM0/DCACHE/CLK
add wave -noupdate -expand -group {CORE 0} -group {DCACHE 0} /system_tb/DUT/CPU/CM0/DCACHE/nRST
add wave -noupdate -expand -group {CORE 0} -group {DCACHE 0} /system_tb/DUT/CPU/CM0/DCACHE/req
add wave -noupdate -expand -group {CORE 0} -group {DCACHE 0} /system_tb/DUT/CPU/CM0/DCACHE/frame
add wave -noupdate -expand -group {CORE 0} -group {DCACHE 0} /system_tb/DUT/CPU/CM0/DCACHE/next_frame
add wave -noupdate -expand -group {CORE 0} -group {DCACHE 0} /system_tb/DUT/CPU/CM0/DCACHE/frame_select
add wave -noupdate -expand -group {CORE 0} -group {DCACHE 0} /system_tb/DUT/CPU/CM0/DCACHE/lru
add wave -noupdate -expand -group {CORE 0} -group {DCACHE 0} /system_tb/DUT/CPU/CM0/DCACHE/next_lru
add wave -noupdate -expand -group {CORE 0} -group {DCACHE 0} /system_tb/DUT/CPU/CM0/DCACHE/prev_dhit
add wave -noupdate -expand -group {CORE 0} -group {DCACHE 0} /system_tb/DUT/CPU/CM0/DCACHE/flush_timer
add wave -noupdate -expand -group {CORE 0} -group {DCACHE 0} /system_tb/DUT/CPU/CM0/DCACHE/next_flush_timer
add wave -noupdate -expand -group {CORE 0} -group {DCACHE 0} /system_tb/DUT/CPU/CM0/DCACHE/state
add wave -noupdate -expand -group {CORE 0} -group {DCACHE 0} /system_tb/DUT/CPU/CM0/DCACHE/prev_state
add wave -noupdate -expand -group {CORE 0} -group {DCACHE 0} /system_tb/DUT/CPU/CM0/DCACHE/next_state
add wave -noupdate -expand -group {CORE 0} -group {DCACHE 0} /system_tb/DUT/CPU/CM0/DCACHE/next_dREN
add wave -noupdate -expand -group {CORE 0} -group {DCACHE 0} /system_tb/DUT/CPU/CM0/DCACHE/next_dWEN
add wave -noupdate -expand -group {CORE 0} -group {DCACHE 0} /system_tb/DUT/CPU/CM0/DCACHE/next_daddr
add wave -noupdate -expand -group {CORE 0} -group {DCACHE 0} /system_tb/DUT/CPU/CM0/DCACHE/next_dstore
add wave -noupdate -expand -group {CORE 0} -group {DCACHE 0} /system_tb/DUT/CPU/CM0/DCACHE/next_ccwrite
add wave -noupdate -expand -group {CORE 0} -group {DCACHE 0} /system_tb/DUT/CPU/CM0/DCACHE/next_cctrans
add wave -noupdate -expand -group {CORE 0} -group {DCACHE 0} /system_tb/DUT/CPU/CM0/DCACHE/snoop_req
add wave -noupdate -expand -group {CORE 0} -group {DCACHE 0} /system_tb/DUT/CPU/CM0/DCACHE/snoop
add wave -noupdate -expand -group {CORE 0} -group {DCACHE 0} /system_tb/DUT/CPU/CM0/DCACHE/snoop_select
add wave -noupdate -expand -group {CORE 0} -group {DCACHE 0} /system_tb/DUT/CPU/CM0/DCACHE/res_set
add wave -noupdate -expand -group {CORE 0} -group {DCACHE 0} /system_tb/DUT/CPU/CM0/DCACHE/valid_res_set
add wave -noupdate -expand -group {CORE 0} -group {DCACHE 0} /system_tb/DUT/CPU/CM0/DCACHE/next_res_set
add wave -noupdate -expand -group {CORE 0} -group {DCACHE 0} /system_tb/DUT/CPU/CM0/DCACHE/next_valid_res_set
add wave -noupdate -expand -group {CORE 0} -group {DCACHE 0} /system_tb/DUT/CPU/CM0/DCACHE/block
add wave -noupdate -expand -group {CORE 0} -group {DCACHE 0} /system_tb/DUT/CPU/CM0/DCACHE/block2
add wave -noupdate /system_tb/DUT/CPU/DP1/rf/registers
add wave -noupdate -group CORE1 /system_tb/DUT/CPU/DP1/PC_INIT
add wave -noupdate -group CORE1 /system_tb/DUT/CPU/DP1/CLK
add wave -noupdate -group CORE1 /system_tb/DUT/CPU/DP1/nRST
add wave -noupdate -group CORE1 /system_tb/DUT/CPU/DP1/next_pc
add wave -noupdate -group CORE1 /system_tb/DUT/CPU/DP1/pc
add wave -noupdate -group CORE1 /system_tb/DUT/CPU/DP1/portA1
add wave -noupdate -group CORE1 /system_tb/DUT/CPU/DP1/portB1
add wave -noupdate -group CORE1 /system_tb/DUT/CPU/DP1/portA2
add wave -noupdate -group CORE1 /system_tb/DUT/CPU/DP1/portB2
add wave -noupdate -group CORE1 /system_tb/DUT/CPU/DP1/control_pipe
add wave -noupdate -group CORE1 /system_tb/DUT/CPU/DP1/stall_flag
add wave -noupdate -group CORE1 /system_tb/DUT/CPU/DP1/stall_check
add wave -noupdate -group CORE1 /system_tb/DUT/CPU/DP1/PCWrite
add wave -noupdate -group CORE1 /system_tb/DUT/CPU/DP1/if_id_write1
add wave -noupdate -group CORE1 /system_tb/DUT/CPU/DP1/if_id_write2
add wave -noupdate -group CORE1 /system_tb/DUT/CPU/DP1/if_flush
add wave -noupdate -group CORE1 /system_tb/DUT/CPU/DP1/id_flush1
add wave -noupdate -group CORE1 /system_tb/DUT/CPU/DP1/id_flush2
add wave -noupdate -group CORE1 /system_tb/DUT/CPU/DP1/branch1
add wave -noupdate -group CORE1 /system_tb/DUT/CPU/DP1/branch2
add wave -noupdate -group CORE1 /system_tb/DUT/CPU/DP1/forwardA1
add wave -noupdate -group CORE1 /system_tb/DUT/CPU/DP1/forwardB1
add wave -noupdate -group CORE1 /system_tb/DUT/CPU/DP1/forwardA2
add wave -noupdate -group CORE1 /system_tb/DUT/CPU/DP1/forwardB2
add wave -noupdate -group CORE1 /system_tb/DUT/CPU/DP1/if_id1
add wave -noupdate -group CORE1 /system_tb/DUT/CPU/DP1/if_id2
add wave -noupdate -group CORE1 /system_tb/DUT/CPU/DP1/id_ex1
add wave -noupdate -group CORE1 /system_tb/DUT/CPU/DP1/id_ex2
add wave -noupdate -group CORE1 -expand /system_tb/DUT/CPU/DP1/ex_mem1
add wave -noupdate -group CORE1 -expand /system_tb/DUT/CPU/DP1/ex_mem2
add wave -noupdate -group CORE1 /system_tb/DUT/CPU/DP1/mem_wb1
add wave -noupdate -group CORE1 /system_tb/DUT/CPU/DP1/mem_wb2
add wave -noupdate -group CORE1 /system_tb/DUT/CPU/DP1/stall
add wave -noupdate -group CORE1 /system_tb/DUT/CPU/DP1/mem_dep
add wave -noupdate -group CORE1 /system_tb/DUT/CPU/DP1/write_selected1
add wave -noupdate -group CORE1 /system_tb/DUT/CPU/DP1/write_selected2
add wave -noupdate -group CORE1 /system_tb/DUT/CPU/DP1/load1
add wave -noupdate -group CORE1 /system_tb/DUT/CPU/DP1/load2
add wave -noupdate -group CORE1 -expand -group {DCACHE 1} /system_tb/DUT/CPU/CM1/DCACHE/CLK
add wave -noupdate -group CORE1 -expand -group {DCACHE 1} /system_tb/DUT/CPU/CM1/DCACHE/nRST
add wave -noupdate -group CORE1 -expand -group {DCACHE 1} /system_tb/DUT/CPU/CM1/DCACHE/req
add wave -noupdate -group CORE1 -expand -group {DCACHE 1} /system_tb/DUT/CPU/CM1/DCACHE/frame
add wave -noupdate -group CORE1 -expand -group {DCACHE 1} /system_tb/DUT/CPU/CM1/DCACHE/next_frame
add wave -noupdate -group CORE1 -expand -group {DCACHE 1} /system_tb/DUT/CPU/CM1/DCACHE/frame_select
add wave -noupdate -group CORE1 -expand -group {DCACHE 1} /system_tb/DUT/CPU/CM1/DCACHE/lru
add wave -noupdate -group CORE1 -expand -group {DCACHE 1} /system_tb/DUT/CPU/CM1/DCACHE/next_lru
add wave -noupdate -group CORE1 -expand -group {DCACHE 1} /system_tb/DUT/CPU/CM1/DCACHE/prev_dhit
add wave -noupdate -group CORE1 -expand -group {DCACHE 1} /system_tb/DUT/CPU/CM1/DCACHE/flush_timer
add wave -noupdate -group CORE1 -expand -group {DCACHE 1} /system_tb/DUT/CPU/CM1/DCACHE/next_flush_timer
add wave -noupdate -group CORE1 -expand -group {DCACHE 1} /system_tb/DUT/CPU/CM1/DCACHE/state
add wave -noupdate -group CORE1 -expand -group {DCACHE 1} /system_tb/DUT/CPU/CM1/DCACHE/prev_state
add wave -noupdate -group CORE1 -expand -group {DCACHE 1} /system_tb/DUT/CPU/CM1/DCACHE/next_state
add wave -noupdate -group CORE1 -expand -group {DCACHE 1} /system_tb/DUT/CPU/CM1/DCACHE/next_dREN
add wave -noupdate -group CORE1 -expand -group {DCACHE 1} /system_tb/DUT/CPU/CM1/DCACHE/next_dWEN
add wave -noupdate -group CORE1 -expand -group {DCACHE 1} /system_tb/DUT/CPU/CM1/DCACHE/next_daddr
add wave -noupdate -group CORE1 -expand -group {DCACHE 1} /system_tb/DUT/CPU/CM1/DCACHE/next_dstore
add wave -noupdate -group CORE1 -expand -group {DCACHE 1} /system_tb/DUT/CPU/CM1/DCACHE/next_ccwrite
add wave -noupdate -group CORE1 -expand -group {DCACHE 1} /system_tb/DUT/CPU/CM1/DCACHE/next_cctrans
add wave -noupdate -group CORE1 -expand -group {DCACHE 1} /system_tb/DUT/CPU/CM1/DCACHE/snoop_req
add wave -noupdate -group CORE1 -expand -group {DCACHE 1} /system_tb/DUT/CPU/CM1/DCACHE/snoop
add wave -noupdate -group CORE1 -expand -group {DCACHE 1} /system_tb/DUT/CPU/CM1/DCACHE/snoop_select
add wave -noupdate -group CORE1 -expand -group {DCACHE 1} /system_tb/DUT/CPU/CM1/DCACHE/res_set
add wave -noupdate -group CORE1 -expand -group {DCACHE 1} /system_tb/DUT/CPU/CM1/DCACHE/valid_res_set
add wave -noupdate -group CORE1 -expand -group {DCACHE 1} /system_tb/DUT/CPU/CM1/DCACHE/next_res_set
add wave -noupdate -group CORE1 -expand -group {DCACHE 1} /system_tb/DUT/CPU/CM1/DCACHE/next_valid_res_set
add wave -noupdate -group CORE1 -expand -group {DCACHE 1} /system_tb/DUT/CPU/CM1/DCACHE/block
add wave -noupdate -group CORE1 -expand -group {DCACHE 1} /system_tb/DUT/CPU/CM1/DCACHE/block2
add wave -noupdate -group CORE1 -group {ICACHE 1} /system_tb/DUT/CPU/CM1/ICACHE/CLK
add wave -noupdate -group CORE1 -group {ICACHE 1} /system_tb/DUT/CPU/CM1/ICACHE/nRST
add wave -noupdate -group CORE1 -group {ICACHE 1} /system_tb/DUT/CPU/CM1/ICACHE/cache
add wave -noupdate -group CORE1 -group {ICACHE 1} /system_tb/DUT/CPU/CM1/ICACHE/next_cache
add wave -noupdate -group CORE1 -group {ICACHE 1} /system_tb/DUT/CPU/CM1/ICACHE/state
add wave -noupdate -group CORE1 -group {ICACHE 1} /system_tb/DUT/CPU/CM1/ICACHE/next_state
add wave -noupdate -group CORE1 -group {ICACHE 1} /system_tb/DUT/CPU/CM1/ICACHE/instr1
add wave -noupdate -group CORE1 -group {ICACHE 1} /system_tb/DUT/CPU/CM1/ICACHE/instr2
add wave -noupdate -group CORE1 -group {ICACHE 1} /system_tb/DUT/CPU/CM1/ICACHE/next_iREN
add wave -noupdate -group CORE1 -group {ICACHE 1} /system_tb/DUT/CPU/CM1/ICACHE/next_iaddr
add wave -noupdate -group CORE1 -group {ICACHE 1} /system_tb/DUT/CPU/CM1/ICACHE/ihit1
add wave -noupdate -group CORE1 -group {ICACHE 1} /system_tb/DUT/CPU/CM1/ICACHE/ihit2
add wave -noupdate -expand -group {Bus Controller} /system_tb/DUT/CPU/CC/CLK
add wave -noupdate -expand -group {Bus Controller} /system_tb/DUT/CPU/CC/nRST
add wave -noupdate -expand -group {Bus Controller} /system_tb/DUT/CPU/CC/state
add wave -noupdate -expand -group {Bus Controller} /system_tb/DUT/CPU/CC/next_state
add wave -noupdate -expand -group {Bus Controller} /system_tb/DUT/CPU/CC/core
add wave -noupdate -expand -group {Bus Controller} /system_tb/DUT/CPU/CC/lru
add wave -noupdate -expand -group {Bus Controller} /system_tb/DUT/CPU/CC/next_core
add wave -noupdate -expand -group {Bus Controller} /system_tb/DUT/CPU/CC/next_lru
add wave -noupdate -expand -group {Bus Controller} /system_tb/DUT/CPU/CC/data_read
add wave -noupdate -expand -group {Bus Controller} /system_tb/DUT/CPU/CC/data_write
add wave -noupdate -expand -group {Bus Controller} /system_tb/DUT/CPU/CC/inst_read
add wave -noupdate -expand -group {Bus Controller} /system_tb/DUT/CPU/CC/next_ramREN
add wave -noupdate -expand -group {Bus Controller} /system_tb/DUT/CPU/CC/next_ramWEN
add wave -noupdate -expand -group {Bus Controller} /system_tb/DUT/CPU/CC/invalidate_check
add wave -noupdate -expand -group {Bus Controller} /system_tb/DUT/CPU/CC/next_ramaddr
add wave -noupdate -expand -group {Bus Controller} /system_tb/DUT/CPU/CC/next_ramstore
add wave -noupdate -expand -group {Bus Controller} /system_tb/DUT/CPU/CC/next_snoop_addr
add wave -noupdate -group RAM /system_tb/DUT/RAM/BAD
add wave -noupdate -group RAM /system_tb/DUT/RAM/LAT
add wave -noupdate -group RAM /system_tb/DUT/RAM/CLK
add wave -noupdate -group RAM /system_tb/DUT/RAM/nRST
add wave -noupdate -group RAM /system_tb/DUT/RAM/count
add wave -noupdate -group RAM /system_tb/DUT/RAM/rstate
add wave -noupdate -group RAM /system_tb/DUT/RAM/q
add wave -noupdate -group RAM /system_tb/DUT/RAM/addr
add wave -noupdate -group RAM /system_tb/DUT/RAM/wren
add wave -noupdate -group RAM /system_tb/DUT/RAM/en
add wave -noupdate /system_tb/DUT/CPU/DP0/control_pipe
add wave -noupdate /system_tb/DUT/CPU/CM0/ICACHE/caif/iload
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {300824427 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 168
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
WaveRestoreZoom {300128245 ps} {301980613 ps}
