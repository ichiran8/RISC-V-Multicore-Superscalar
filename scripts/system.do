onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /system_tb/DUT/CPUCLK
add wave -noupdate /system_tb/DUT/nRST
add wave -noupdate /system_tb/DUT/CLK
add wave -noupdate /system_tb/DUT/halt
add wave -noupdate -divider Datapath
add wave -noupdate /system_tb/DUT/CPU/DP/dpif/imemload
add wave -noupdate /system_tb/DUT/CPU/DP/pc
add wave -noupdate /system_tb/DUT/CPU/dcif/ihit
add wave -noupdate /system_tb/DUT/CPU/dcif/dhit
add wave -noupdate -divider {Register File}
add wave -noupdate -group {Register File} /system_tb/DUT/CPU/DP/rf/registers
add wave -noupdate -group {Register File} /system_tb/DUT/CPU/DP/rf/rfif/WEN
add wave -noupdate -group {Register File} /system_tb/DUT/CPU/DP/rf/rfif/wsel
add wave -noupdate -group {Register File} /system_tb/DUT/CPU/DP/rf/rfif/rsel1
add wave -noupdate -group {Register File} /system_tb/DUT/CPU/DP/rf/rfif/rsel2
add wave -noupdate -group {Register File} /system_tb/DUT/CPU/DP/rf/rfif/wdat
add wave -noupdate -group {Register File} /system_tb/DUT/CPU/DP/rf/rfif/rdat1
add wave -noupdate -group {Register File} /system_tb/DUT/CPU/DP/rf/rfif/rdat2
add wave -noupdate -divider {Memory Control}
add wave -noupdate -group {Memory Control} /system_tb/DUT/CPU/CC/ccif/iREN
add wave -noupdate -group {Memory Control} /system_tb/DUT/CPU/CC/ccif/dREN
add wave -noupdate -group {Memory Control} /system_tb/DUT/CPU/CC/ccif/dWEN
add wave -noupdate -group {Memory Control} /system_tb/DUT/CPU/CC/ccif/iload
add wave -noupdate -group {Memory Control} /system_tb/DUT/CPU/CC/ccif/dload
add wave -noupdate -group {Memory Control} /system_tb/DUT/CPU/CC/ccif/dstore
add wave -noupdate -group {Memory Control} /system_tb/DUT/CPU/CC/ccif/iaddr
add wave -noupdate -group {Memory Control} /system_tb/DUT/CPU/CC/ccif/daddr
add wave -noupdate -divider {Pipeline Latches}
add wave -noupdate -group IF_ID /system_tb/DUT/CPU/DP/if_id.instruction
add wave -noupdate -group IF_ID /system_tb/DUT/CPU/DP/if_id.pc_add
add wave -noupdate -group IF_ID /system_tb/DUT/CPU/DP/if_id.curr_pc
add wave -noupdate -group ID_EX /system_tb/DUT/CPU/DP/id_ex.rdat1
add wave -noupdate -group ID_EX /system_tb/DUT/CPU/DP/id_ex.rdat2
add wave -noupdate -group ID_EX /system_tb/DUT/CPU/DP/id_ex.pc_add
add wave -noupdate -group ID_EX /system_tb/DUT/CPU/DP/id_ex.imm_gen
add wave -noupdate -group ID_EX /system_tb/DUT/CPU/DP/id_ex.curr_pc
add wave -noupdate -group ID_EX /system_tb/DUT/CPU/DP/id_ex.alu_op
add wave -noupdate -group ID_EX /system_tb/DUT/CPU/DP/id_ex.alu_src
add wave -noupdate -group ID_EX /system_tb/DUT/CPU/DP/id_ex.regwrite
add wave -noupdate -group ID_EX /system_tb/DUT/CPU/DP/id_ex.memwrite
add wave -noupdate -group ID_EX /system_tb/DUT/CPU/DP/id_ex.memread
add wave -noupdate -group ID_EX /system_tb/DUT/CPU/DP/id_ex.memreg
add wave -noupdate -group ID_EX /system_tb/DUT/CPU/DP/id_ex.jump
add wave -noupdate -group ID_EX /system_tb/DUT/CPU/DP/id_ex.auipc
add wave -noupdate -group ID_EX /system_tb/DUT/CPU/DP/id_ex.halt
add wave -noupdate -group ID_EX /system_tb/DUT/CPU/DP/id_ex.jalr
add wave -noupdate -group ID_EX /system_tb/DUT/CPU/DP/id_ex.lui
add wave -noupdate -group ID_EX /system_tb/DUT/CPU/DP/id_ex.wsel
add wave -noupdate -group ID_EX /system_tb/DUT/CPU/DP/id_ex.rsel1
add wave -noupdate -group ID_EX /system_tb/DUT/CPU/DP/id_ex.rsel2
add wave -noupdate -group ID_EX /system_tb/DUT/CPU/DP/id_ex.branch_type
add wave -noupdate -group EX_MEM /system_tb/DUT/CPU/DP/ex_mem.pc_add
add wave -noupdate -group EX_MEM /system_tb/DUT/CPU/DP/ex_mem.imm_gen
add wave -noupdate -group EX_MEM /system_tb/DUT/CPU/DP/ex_mem.dmemstore
add wave -noupdate -group EX_MEM /system_tb/DUT/CPU/DP/ex_mem.curr_pc
add wave -noupdate -group EX_MEM /system_tb/DUT/CPU/DP/ex_mem.regwrite
add wave -noupdate -group EX_MEM /system_tb/DUT/CPU/DP/ex_mem.memwrite
add wave -noupdate -group EX_MEM /system_tb/DUT/CPU/DP/ex_mem.memread
add wave -noupdate -group EX_MEM /system_tb/DUT/CPU/DP/ex_mem.memreg
add wave -noupdate -group EX_MEM /system_tb/DUT/CPU/DP/ex_mem.jump
add wave -noupdate -group EX_MEM /system_tb/DUT/CPU/DP/ex_mem.halt
add wave -noupdate -group EX_MEM /system_tb/DUT/CPU/DP/ex_mem.jalr
add wave -noupdate -group EX_MEM /system_tb/DUT/CPU/DP/ex_mem.wsel
add wave -noupdate -group EX_MEM /system_tb/DUT/CPU/DP/ex_mem.write_selected
add wave -noupdate -group MEM_WB /system_tb/DUT/CPU/DP/mem_wb.memload
add wave -noupdate -group MEM_WB /system_tb/DUT/CPU/DP/mem_wb.write_selected
add wave -noupdate -group MEM_WB /system_tb/DUT/CPU/DP/mem_wb.regwrite
add wave -noupdate -group MEM_WB /system_tb/DUT/CPU/DP/mem_wb.memreg
add wave -noupdate -group MEM_WB /system_tb/DUT/CPU/DP/mem_wb.halt
add wave -noupdate -group MEM_WB /system_tb/DUT/CPU/DP/mem_wb.write_selected
add wave -noupdate -group MEM_WB /system_tb/DUT/CPU/DP/mem_wb.wsel
add wave -noupdate -divider Forwarding
add wave -noupdate -group Forwarding /system_tb/DUT/CPU/DP/portA
add wave -noupdate -group Forwarding /system_tb/DUT/CPU/DP/portB
add wave -noupdate -group Forwarding /system_tb/DUT/CPU/DP/forwardA
add wave -noupdate -group Forwarding /system_tb/DUT/CPU/DP/forwardB
add wave -noupdate -group ALU /system_tb/DUT/CPU/DP/alu/aluif/rda
add wave -noupdate -group ALU /system_tb/DUT/CPU/DP/alu/aluif/rdb
add wave -noupdate -group ALU /system_tb/DUT/CPU/DP/alu/aluif/result
add wave -noupdate -group ALU /system_tb/DUT/CPU/DP/alu/aluif/zero
add wave -noupdate -group ALU /system_tb/DUT/CPU/DP/alu/aluif/negative
add wave -noupdate -group ALU /system_tb/DUT/CPU/DP/alu/aluif/overflow
add wave -noupdate -group ALU /system_tb/DUT/CPU/DP/alu/aluif/alu_op
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {659895 ps} 0}
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
WaveRestoreZoom {1312473900 ps} {1312922058 ps}
