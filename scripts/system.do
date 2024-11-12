onerror {resume}
quietly virtual function -install /system_tb/DUT/CPU/ccif -env /system_tb/DUT/CPU/ccif { &{/system_tb/DUT/CPU/ccif/iwait, /system_tb/DUT/CPU/ccif/dwait, /system_tb/DUT/CPU/ccif/iREN, /system_tb/DUT/CPU/ccif/dREN, /system_tb/DUT/CPU/ccif/dWEN, /system_tb/DUT/CPU/ccif/iload, /system_tb/DUT/CPU/ccif/dload, /system_tb/DUT/CPU/ccif/dstore, /system_tb/DUT/CPU/ccif/iaddr, /system_tb/DUT/CPU/ccif/daddr, /system_tb/DUT/CPU/ccif/ccwait, /system_tb/DUT/CPU/ccif/ccinv, /system_tb/DUT/CPU/ccif/ccwrite, /system_tb/DUT/CPU/ccif/cctrans, /system_tb/DUT/CPU/ccif/ccsnoopaddr, /system_tb/DUT/CPU/ccif/ramWEN, /system_tb/DUT/CPU/ccif/ramREN, /system_tb/DUT/CPU/ccif/ramstate, /system_tb/DUT/CPU/ccif/ramaddr, /system_tb/DUT/CPU/ccif/ramstore, /system_tb/DUT/CPU/ccif/ramload }} CACHE_CONTROL
quietly WaveActivateNextPane {} 0
add wave -noupdate /system_tb/DUT/CPUCLK
add wave -noupdate /system_tb/DUT/nRST
add wave -noupdate /system_tb/DUT/CLK
add wave -noupdate /system_tb/syif/halt
add wave -noupdate -divider Datapaths
add wave -noupdate -group {DATAPATH 0} /system_tb/DUT/CPU/DP0/CLK
add wave -noupdate -group {DATAPATH 0} /system_tb/DUT/CPU/DP0/nRST
add wave -noupdate -group {DATAPATH 0} /system_tb/DUT/CPU/DP0/next_pc
add wave -noupdate -group {DATAPATH 0} /system_tb/DUT/CPU/DP0/pc
add wave -noupdate -group {DATAPATH 0} /system_tb/DUT/CPU/DP0/portA
add wave -noupdate -group {DATAPATH 0} /system_tb/DUT/CPU/DP0/portB
add wave -noupdate -group {DATAPATH 0} /system_tb/DUT/CPU/DP0/write_back
add wave -noupdate -group {DATAPATH 0} /system_tb/DUT/CPU/DP0/control_pipe
add wave -noupdate -group {DATAPATH 0} /system_tb/DUT/CPU/DP0/switch1
add wave -noupdate -group {DATAPATH 0} /system_tb/DUT/CPU/DP0/PCWrite
add wave -noupdate -group {DATAPATH 0} /system_tb/DUT/CPU/DP0/if_id_write
add wave -noupdate -group {DATAPATH 0} /system_tb/DUT/CPU/DP0/if_flush
add wave -noupdate -group {DATAPATH 0} /system_tb/DUT/CPU/DP0/id_flush
add wave -noupdate -group {DATAPATH 0} /system_tb/DUT/CPU/DP0/ex_flush
add wave -noupdate -group {DATAPATH 0} /system_tb/DUT/CPU/DP0/branch
add wave -noupdate -group {DATAPATH 0} /system_tb/DUT/CPU/DP0/forwardA
add wave -noupdate -group {DATAPATH 0} /system_tb/DUT/CPU/DP0/forwardB
add wave -noupdate -group {DATAPATH 0} -expand /system_tb/DUT/CPU/DP0/if_id
add wave -noupdate -group {DATAPATH 0} -expand /system_tb/DUT/CPU/DP0/id_ex
add wave -noupdate -group {DATAPATH 0} -expand /system_tb/DUT/CPU/DP0/ex_mem
add wave -noupdate -group {DATAPATH 0} -expand /system_tb/DUT/CPU/DP0/mem_wb
add wave -noupdate -group {DATAPATH 0} /system_tb/DUT/CPU/DP0/write_selected
add wave -noupdate -group {DATAPATH 0} /system_tb/DUT/CPU/DP0/aluif/result
add wave -noupdate -group {DATAPATH 0} /system_tb/DUT/CPU/DP0/aluif/rda
add wave -noupdate -group {DATAPATH 0} /system_tb/DUT/CPU/DP0/aluif/rdb
add wave -noupdate -group {DATAPATH 0} /system_tb/DUT/CPU/DP0/load
add wave -noupdate -group {DPIF 0} /system_tb/DUT/CPU/DP0/dpif/halt
add wave -noupdate -group {DPIF 0} /system_tb/DUT/CPU/DP0/dpif/ihit
add wave -noupdate -group {DPIF 0} /system_tb/DUT/CPU/DP0/dpif/imemREN
add wave -noupdate -group {DPIF 0} /system_tb/DUT/CPU/DP0/dpif/imemload
add wave -noupdate -group {DPIF 0} /system_tb/DUT/CPU/DP0/dpif/imemaddr
add wave -noupdate -group {DPIF 0} /system_tb/DUT/CPU/DP0/dpif/dhit
add wave -noupdate -group {DPIF 0} /system_tb/DUT/CPU/DP0/dpif/datomic
add wave -noupdate -group {DPIF 0} /system_tb/DUT/CPU/DP0/dpif/dmemREN
add wave -noupdate -group {DPIF 0} /system_tb/DUT/CPU/DP0/dpif/dmemWEN
add wave -noupdate -group {DPIF 0} /system_tb/DUT/CPU/DP0/dpif/flushed
add wave -noupdate -group {DPIF 0} /system_tb/DUT/CPU/DP0/dpif/dmemload
add wave -noupdate -group {DPIF 0} /system_tb/DUT/CPU/DP0/dpif/dmemstore
add wave -noupdate -group {DPIF 0} /system_tb/DUT/CPU/DP0/dpif/dmemaddr
add wave -noupdate -group {DATAPATH 1} /system_tb/DUT/CPU/DP1/CLK
add wave -noupdate -group {DATAPATH 1} /system_tb/DUT/CPU/DP1/nRST
add wave -noupdate -group {DATAPATH 1} /system_tb/DUT/CPU/DP1/next_pc
add wave -noupdate -group {DATAPATH 1} /system_tb/DUT/CPU/DP1/pc
add wave -noupdate -group {DATAPATH 1} /system_tb/DUT/CPU/DP1/portA
add wave -noupdate -group {DATAPATH 1} /system_tb/DUT/CPU/DP1/portB
add wave -noupdate -group {DATAPATH 1} /system_tb/DUT/CPU/DP1/write_back
add wave -noupdate -group {DATAPATH 1} /system_tb/DUT/CPU/DP1/control_pipe
add wave -noupdate -group {DATAPATH 1} /system_tb/DUT/CPU/DP1/switch1
add wave -noupdate -group {DATAPATH 1} /system_tb/DUT/CPU/DP1/PCWrite
add wave -noupdate -group {DATAPATH 1} /system_tb/DUT/CPU/DP1/if_id_write
add wave -noupdate -group {DATAPATH 1} /system_tb/DUT/CPU/DP1/if_flush
add wave -noupdate -group {DATAPATH 1} /system_tb/DUT/CPU/DP1/id_flush
add wave -noupdate -group {DATAPATH 1} /system_tb/DUT/CPU/DP1/ex_flush
add wave -noupdate -group {DATAPATH 1} /system_tb/DUT/CPU/DP1/branch
add wave -noupdate -group {DATAPATH 1} /system_tb/DUT/CPU/DP1/forwardA
add wave -noupdate -group {DATAPATH 1} /system_tb/DUT/CPU/DP1/forwardB
add wave -noupdate -group {DATAPATH 1} -expand /system_tb/DUT/CPU/DP1/if_id
add wave -noupdate -group {DATAPATH 1} /system_tb/DUT/CPU/DP1/id_ex
add wave -noupdate -group {DATAPATH 1} /system_tb/DUT/CPU/DP1/ex_mem
add wave -noupdate -group {DATAPATH 1} /system_tb/DUT/CPU/DP1/mem_wb
add wave -noupdate -group {DATAPATH 1} /system_tb/DUT/CPU/DP1/write_selected
add wave -noupdate -group {DATAPATH 1} /system_tb/DUT/CPU/DP1/load
add wave -noupdate -group {DPIF 1} /system_tb/DUT/CPU/DP1/dpif/halt
add wave -noupdate -group {DPIF 1} /system_tb/DUT/CPU/DP1/dpif/ihit
add wave -noupdate -group {DPIF 1} /system_tb/DUT/CPU/DP1/dpif/imemREN
add wave -noupdate -group {DPIF 1} /system_tb/DUT/CPU/DP1/dpif/imemload
add wave -noupdate -group {DPIF 1} /system_tb/DUT/CPU/DP1/dpif/imemaddr
add wave -noupdate -group {DPIF 1} /system_tb/DUT/CPU/DP1/dpif/dhit
add wave -noupdate -group {DPIF 1} /system_tb/DUT/CPU/DP1/dpif/datomic
add wave -noupdate -group {DPIF 1} /system_tb/DUT/CPU/DP1/dpif/dmemREN
add wave -noupdate -group {DPIF 1} /system_tb/DUT/CPU/DP1/dpif/dmemWEN
add wave -noupdate -group {DPIF 1} /system_tb/DUT/CPU/DP1/dpif/flushed
add wave -noupdate -group {DPIF 1} /system_tb/DUT/CPU/DP1/dpif/dmemload
add wave -noupdate -group {DPIF 1} /system_tb/DUT/CPU/DP1/dpif/dmemstore
add wave -noupdate -group {DPIF 1} /system_tb/DUT/CPU/DP1/dpif/dmemaddr
add wave -noupdate -divider {Bus Control}
add wave -noupdate -group BUS_CONTROL /system_tb/DUT/CPU/CC/CLK
add wave -noupdate -group BUS_CONTROL /system_tb/DUT/CPU/CC/nRST
add wave -noupdate -group BUS_CONTROL /system_tb/DUT/CPU/CC/next_ccwait
add wave -noupdate -group BUS_CONTROL /system_tb/DUT/CPU/CC/state
add wave -noupdate -group BUS_CONTROL /system_tb/DUT/CPU/CC/next_state
add wave -noupdate -group BUS_CONTROL /system_tb/DUT/CPU/CC/core
add wave -noupdate -group BUS_CONTROL /system_tb/DUT/CPU/CC/lru
add wave -noupdate -group BUS_CONTROL /system_tb/DUT/CPU/CC/next_core
add wave -noupdate -group BUS_CONTROL /system_tb/DUT/CPU/CC/next_lru
add wave -noupdate -group BUS_CONTROL /system_tb/DUT/CPU/CC/data_read
add wave -noupdate -group BUS_CONTROL /system_tb/DUT/CPU/CC/data_write
add wave -noupdate -group BUS_CONTROL /system_tb/DUT/CPU/CC/inst_read
add wave -noupdate -group BUS_CONTROL /system_tb/DUT/CPU/CC/next_ramREN
add wave -noupdate -group BUS_CONTROL /system_tb/DUT/CPU/CC/next_ramWEN
add wave -noupdate -group BUS_CONTROL /system_tb/DUT/CPU/CC/next_ramaddr
add wave -noupdate -group BUS_CONTROL /system_tb/DUT/CPU/CC/next_ramstore
add wave -noupdate -group BUS_CC /system_tb/DUT/CPU/CC/cc/iwait
add wave -noupdate -group BUS_CC /system_tb/DUT/CPU/CC/cc/dwait
add wave -noupdate -group BUS_CC /system_tb/DUT/CPU/CC/cc/iREN
add wave -noupdate -group BUS_CC /system_tb/DUT/CPU/CC/cc/dREN
add wave -noupdate -group BUS_CC /system_tb/DUT/CPU/CC/cc/dWEN
add wave -noupdate -group BUS_CC /system_tb/DUT/CPU/CC/cc/iload
add wave -noupdate -group BUS_CC /system_tb/DUT/CPU/CC/cc/dload
add wave -noupdate -group BUS_CC /system_tb/DUT/CPU/CC/cc/dstore
add wave -noupdate -group BUS_CC /system_tb/DUT/CPU/CC/cc/iaddr
add wave -noupdate -group BUS_CC /system_tb/DUT/CPU/CC/cc/daddr
add wave -noupdate -group BUS_CC /system_tb/DUT/CPU/CC/cc/ccwait
add wave -noupdate -group BUS_CC /system_tb/DUT/CPU/CC/cc/ccinv
add wave -noupdate -group BUS_CC /system_tb/DUT/CPU/CC/cc/ccwrite
add wave -noupdate -group BUS_CC /system_tb/DUT/CPU/CC/cc/cctrans
add wave -noupdate -group BUS_CC /system_tb/DUT/CPU/CC/cc/ccsnoopaddr
add wave -noupdate -group BUS_CC /system_tb/DUT/CPU/CC/cc/ramWEN
add wave -noupdate -group BUS_CC /system_tb/DUT/CPU/CC/cc/ramREN
add wave -noupdate -group BUS_CC /system_tb/DUT/CPU/CC/cc/ramstate
add wave -noupdate -group BUS_CC /system_tb/DUT/CPU/CC/cc/ramaddr
add wave -noupdate -group BUS_CC /system_tb/DUT/CPU/CC/cc/ramstore
add wave -noupdate -group BUS_CC /system_tb/DUT/CPU/CC/cc/ramload
add wave -noupdate -divider {Cache Control}
add wave -noupdate -group CACHE_CONTROL /system_tb/DUT/CPU/ccif/iwait
add wave -noupdate -group CACHE_CONTROL /system_tb/DUT/CPU/ccif/dwait
add wave -noupdate -group CACHE_CONTROL /system_tb/DUT/CPU/ccif/iREN
add wave -noupdate -group CACHE_CONTROL /system_tb/DUT/CPU/ccif/dREN
add wave -noupdate -group CACHE_CONTROL /system_tb/DUT/CPU/ccif/dWEN
add wave -noupdate -group CACHE_CONTROL /system_tb/DUT/CPU/ccif/iload
add wave -noupdate -group CACHE_CONTROL /system_tb/DUT/CPU/ccif/dload
add wave -noupdate -group CACHE_CONTROL /system_tb/DUT/CPU/ccif/dstore
add wave -noupdate -group CACHE_CONTROL /system_tb/DUT/CPU/ccif/iaddr
add wave -noupdate -group CACHE_CONTROL /system_tb/DUT/CPU/ccif/daddr
add wave -noupdate -group CACHE_CONTROL /system_tb/DUT/CPU/ccif/ccwait
add wave -noupdate -group CACHE_CONTROL /system_tb/DUT/CPU/ccif/ccinv
add wave -noupdate -group CACHE_CONTROL /system_tb/DUT/CPU/ccif/ccwrite
add wave -noupdate -group CACHE_CONTROL /system_tb/DUT/CPU/ccif/cctrans
add wave -noupdate -group CACHE_CONTROL /system_tb/DUT/CPU/ccif/ccsnoopaddr
add wave -noupdate -group CACHE_CONTROL /system_tb/DUT/CPU/ccif/ramWEN
add wave -noupdate -group CACHE_CONTROL /system_tb/DUT/CPU/ccif/ramREN
add wave -noupdate -group CACHE_CONTROL /system_tb/DUT/CPU/ccif/ramstate
add wave -noupdate -group CACHE_CONTROL /system_tb/DUT/CPU/ccif/ramaddr
add wave -noupdate -group CACHE_CONTROL /system_tb/DUT/CPU/ccif/ramstore
add wave -noupdate -group CACHE_CONTROL /system_tb/DUT/CPU/ccif/ramload
add wave -noupdate -divider {Cache Interfaces}
add wave -noupdate -group {CIF 0} /system_tb/DUT/CPU/cif0/iwait
add wave -noupdate -group {CIF 0} /system_tb/DUT/CPU/cif0/dwait
add wave -noupdate -group {CIF 0} /system_tb/DUT/CPU/cif0/iREN
add wave -noupdate -group {CIF 0} /system_tb/DUT/CPU/cif0/dREN
add wave -noupdate -group {CIF 0} /system_tb/DUT/CPU/cif0/dWEN
add wave -noupdate -group {CIF 0} /system_tb/DUT/CPU/cif0/iload
add wave -noupdate -group {CIF 0} /system_tb/DUT/CPU/cif0/dload
add wave -noupdate -group {CIF 0} /system_tb/DUT/CPU/cif0/dstore
add wave -noupdate -group {CIF 0} /system_tb/DUT/CPU/cif0/iaddr
add wave -noupdate -group {CIF 0} /system_tb/DUT/CPU/cif0/daddr
add wave -noupdate -group {CIF 0} /system_tb/DUT/CPU/cif0/ccwait
add wave -noupdate -group {CIF 0} /system_tb/DUT/CPU/cif0/ccinv
add wave -noupdate -group {CIF 0} /system_tb/DUT/CPU/cif0/ccwrite
add wave -noupdate -group {CIF 0} /system_tb/DUT/CPU/cif0/cctrans
add wave -noupdate -group {CIF 0} /system_tb/DUT/CPU/cif0/ccsnoopaddr
add wave -noupdate -group {CIF 1} /system_tb/DUT/CPU/cif1/iwait
add wave -noupdate -group {CIF 1} /system_tb/DUT/CPU/cif1/dwait
add wave -noupdate -group {CIF 1} /system_tb/DUT/CPU/cif1/iREN
add wave -noupdate -group {CIF 1} /system_tb/DUT/CPU/cif1/dREN
add wave -noupdate -group {CIF 1} /system_tb/DUT/CPU/cif1/dWEN
add wave -noupdate -group {CIF 1} /system_tb/DUT/CPU/cif1/iload
add wave -noupdate -group {CIF 1} /system_tb/DUT/CPU/cif1/dload
add wave -noupdate -group {CIF 1} /system_tb/DUT/CPU/cif1/dstore
add wave -noupdate -group {CIF 1} /system_tb/DUT/CPU/cif1/iaddr
add wave -noupdate -group {CIF 1} /system_tb/DUT/CPU/cif1/daddr
add wave -noupdate -group {CIF 1} /system_tb/DUT/CPU/cif1/ccwait
add wave -noupdate -group {CIF 1} /system_tb/DUT/CPU/cif1/ccinv
add wave -noupdate -group {CIF 1} /system_tb/DUT/CPU/cif1/ccwrite
add wave -noupdate -group {CIF 1} /system_tb/DUT/CPU/cif1/cctrans
add wave -noupdate -group {CIF 1} /system_tb/DUT/CPU/cif1/ccsnoopaddr
add wave -noupdate -divider Caches
add wave -noupdate -group {DCACHE 0} /system_tb/DUT/CPU/CM0/DCACHE/CLK
add wave -noupdate -group {DCACHE 0} /system_tb/DUT/CPU/CM0/DCACHE/nRST
add wave -noupdate -group {DCACHE 0} /system_tb/DUT/CPU/CM0/DCACHE/req
add wave -noupdate -group {DCACHE 0} /system_tb/DUT/CPU/CM0/DCACHE/frame
add wave -noupdate -group {DCACHE 0} /system_tb/DUT/CPU/CM0/DCACHE/next_frame
add wave -noupdate -group {DCACHE 0} /system_tb/DUT/CPU/CM0/DCACHE/frame_select
add wave -noupdate -group {DCACHE 0} /system_tb/DUT/CPU/CM0/DCACHE/lru
add wave -noupdate -group {DCACHE 0} /system_tb/DUT/CPU/CM0/DCACHE/next_lru
add wave -noupdate -group {DCACHE 0} /system_tb/DUT/CPU/CM0/DCACHE/prev_dhit
add wave -noupdate -group {DCACHE 0} /system_tb/DUT/CPU/CM0/DCACHE/flush_timer
add wave -noupdate -group {DCACHE 0} /system_tb/DUT/CPU/CM0/DCACHE/next_flush_timer
add wave -noupdate -group {DCACHE 0} /system_tb/DUT/CPU/CM0/DCACHE/state
add wave -noupdate -group {DCACHE 0} /system_tb/DUT/CPU/CM0/DCACHE/next_state
add wave -noupdate -group {DCACHE 0} /system_tb/DUT/CPU/CM0/DCACHE/next_dREN
add wave -noupdate -group {DCACHE 0} /system_tb/DUT/CPU/CM0/DCACHE/next_dWEN
add wave -noupdate -group {DCACHE 0} /system_tb/DUT/CPU/CM0/DCACHE/next_daddr
add wave -noupdate -group {DCACHE 0} /system_tb/DUT/CPU/CM0/DCACHE/next_dstore
add wave -noupdate -group {DCACHE 0} /system_tb/DUT/CPU/CM0/DCACHE/next_ccwrite
add wave -noupdate -group {DCACHE 0} /system_tb/DUT/CPU/CM0/DCACHE/next_cctrans
add wave -noupdate -group {DCACHE 0} /system_tb/DUT/CPU/CM0/DCACHE/res_set
add wave -noupdate -group {DCACHE 0} /system_tb/DUT/CPU/CM0/DCACHE/valid_res_set
add wave -noupdate -group {DCACHE 0} /system_tb/DUT/CPU/CM0/DCACHE/next_res_set
add wave -noupdate -group {DCACHE 0} /system_tb/DUT/CPU/CM0/DCACHE/next_valid_res_set
add wave -noupdate -group {DCACHE 0} /system_tb/DUT/CPU/CM0/DCACHE/snoop_req
add wave -noupdate -group {DCACHE 0} /system_tb/DUT/CPU/CM0/DCACHE/snoop
add wave -noupdate -group {DCACHE 0} /system_tb/DUT/CPU/CM0/DCACHE/snoop_select
add wave -noupdate -group {ICACHE 0} /system_tb/DUT/CPU/CM0/ICACHE/CLK
add wave -noupdate -group {ICACHE 0} /system_tb/DUT/CPU/CM0/ICACHE/nRST
add wave -noupdate -group {ICACHE 0} /system_tb/DUT/CPU/CM0/ICACHE/cache
add wave -noupdate -group {ICACHE 0} /system_tb/DUT/CPU/CM0/ICACHE/next_cache
add wave -noupdate -group {ICACHE 0} /system_tb/DUT/CPU/CM0/ICACHE/state
add wave -noupdate -group {ICACHE 0} /system_tb/DUT/CPU/CM0/ICACHE/next_state
add wave -noupdate -group {ICACHE 0} /system_tb/DUT/CPU/CM0/ICACHE/icheck
add wave -noupdate -group {ICACHE 0} /system_tb/DUT/CPU/CM0/ICACHE/next_iREN
add wave -noupdate -group {ICACHE 0} /system_tb/DUT/CPU/CM0/ICACHE/next_iaddr
add wave -noupdate -group {ICACHE 0} /system_tb/DUT/CPU/CM0/ICACHE/test_iREN
add wave -noupdate -group {ICACHE 0} /system_tb/DUT/CPU/CM0/ICACHE/test_iaddr
add wave -noupdate -group {DCACHE 1} /system_tb/DUT/CPU/CM1/DCACHE/CLK
add wave -noupdate -group {DCACHE 1} /system_tb/DUT/CPU/CM1/DCACHE/nRST
add wave -noupdate -group {DCACHE 1} /system_tb/DUT/CPU/CM1/DCACHE/req
add wave -noupdate -group {DCACHE 1} /system_tb/DUT/CPU/CM1/DCACHE/frame
add wave -noupdate -group {DCACHE 1} /system_tb/DUT/CPU/CM1/DCACHE/next_frame
add wave -noupdate -group {DCACHE 1} /system_tb/DUT/CPU/CM1/DCACHE/frame_select
add wave -noupdate -group {DCACHE 1} /system_tb/DUT/CPU/CM1/DCACHE/lru
add wave -noupdate -group {DCACHE 1} /system_tb/DUT/CPU/CM1/DCACHE/next_lru
add wave -noupdate -group {DCACHE 1} /system_tb/DUT/CPU/CM1/DCACHE/prev_dhit
add wave -noupdate -group {DCACHE 1} /system_tb/DUT/CPU/CM1/DCACHE/flush_timer
add wave -noupdate -group {DCACHE 1} /system_tb/DUT/CPU/CM1/DCACHE/next_flush_timer
add wave -noupdate -group {DCACHE 1} /system_tb/DUT/CPU/CM1/DCACHE/state
add wave -noupdate -group {DCACHE 1} /system_tb/DUT/CPU/CM1/DCACHE/next_state
add wave -noupdate -group {DCACHE 1} /system_tb/DUT/CPU/CM1/DCACHE/next_dREN
add wave -noupdate -group {DCACHE 1} /system_tb/DUT/CPU/CM1/DCACHE/next_dWEN
add wave -noupdate -group {DCACHE 1} /system_tb/DUT/CPU/CM1/DCACHE/next_daddr
add wave -noupdate -group {DCACHE 1} /system_tb/DUT/CPU/CM1/DCACHE/next_dstore
add wave -noupdate -group {DCACHE 1} /system_tb/DUT/CPU/CM1/DCACHE/next_ccwrite
add wave -noupdate -group {DCACHE 1} /system_tb/DUT/CPU/CM1/DCACHE/next_cctrans
add wave -noupdate -group {DCACHE 1} /system_tb/DUT/CPU/CM1/DCACHE/res_set
add wave -noupdate -group {DCACHE 1} /system_tb/DUT/CPU/CM1/DCACHE/valid_res_set
add wave -noupdate -group {DCACHE 1} /system_tb/DUT/CPU/CM1/DCACHE/next_res_set
add wave -noupdate -group {DCACHE 1} /system_tb/DUT/CPU/CM1/DCACHE/next_valid_res_set
add wave -noupdate -group {DCACHE 1} /system_tb/DUT/CPU/CM1/DCACHE/snoop_req
add wave -noupdate -group {DCACHE 1} /system_tb/DUT/CPU/CM1/DCACHE/snoop
add wave -noupdate -group {DCACHE 1} /system_tb/DUT/CPU/CM1/DCACHE/snoop_select
add wave -noupdate -group {ICACHE 1} /system_tb/DUT/CPU/CM1/ICACHE/CLK
add wave -noupdate -group {ICACHE 1} /system_tb/DUT/CPU/CM1/ICACHE/nRST
add wave -noupdate -group {ICACHE 1} /system_tb/DUT/CPU/CM1/ICACHE/cache
add wave -noupdate -group {ICACHE 1} /system_tb/DUT/CPU/CM1/ICACHE/next_cache
add wave -noupdate -group {ICACHE 1} /system_tb/DUT/CPU/CM1/ICACHE/state
add wave -noupdate -group {ICACHE 1} /system_tb/DUT/CPU/CM1/ICACHE/next_state
add wave -noupdate -group {ICACHE 1} /system_tb/DUT/CPU/CM1/ICACHE/icheck
add wave -noupdate -group {ICACHE 1} /system_tb/DUT/CPU/CM1/ICACHE/next_iREN
add wave -noupdate -group {ICACHE 1} /system_tb/DUT/CPU/CM1/ICACHE/next_iaddr
add wave -noupdate -group {ICACHE 1} /system_tb/DUT/CPU/CM1/ICACHE/test_iREN
add wave -noupdate -group {ICACHE 1} /system_tb/DUT/CPU/CM1/ICACHE/test_iaddr
add wave -noupdate -divider RAM
add wave -noupdate -group RAM /system_tb/DUT/RAM/ramif/ramREN
add wave -noupdate -group RAM /system_tb/DUT/RAM/ramif/ramWEN
add wave -noupdate -group RAM /system_tb/DUT/RAM/ramif/ramaddr
add wave -noupdate -group RAM /system_tb/DUT/RAM/ramif/ramstore
add wave -noupdate -group RAM /system_tb/DUT/RAM/ramif/ramload
add wave -noupdate -group RAM /system_tb/DUT/RAM/ramif/ramstate
add wave -noupdate -group RAM /system_tb/DUT/RAM/ramif/memREN
add wave -noupdate -group RAM /system_tb/DUT/RAM/ramif/memWEN
add wave -noupdate -group RAM /system_tb/DUT/RAM/ramif/memaddr
add wave -noupdate -group RAM /system_tb/DUT/RAM/ramif/memstore
add wave -noupdate /system_tb/DUT/CPU/CM0/dcif/datomic
add wave -noupdate /system_tb/DUT/CPU/CM1/dcif/datomic
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {5782148 ps} 0}
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
WaveRestoreZoom {4169650 ps} {6607543 ps}
