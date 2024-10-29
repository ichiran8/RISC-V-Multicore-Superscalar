org 0x000

li $10, 1
li $12, 8000

sw $10, 0($12) # pr_wr, I -> M core1
ori $1, $0, 1 # bus_rd & bus_wb, core1 M -> S

halt

org 0x0200

li $10, 1
li $12, 8000

ori $1, $0, 1 # bus_rdX, core2 stay in I
lw $10, 0($12) # pr_rd, I -> S core2

halt
