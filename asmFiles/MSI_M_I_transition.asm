# core 1
org 0x000

li $10, 1
li $12, 8000

ori $1, $0, 1 # bus_rd, core1 stay in I
sw $10, 0($12) # pr_wr, I -> M core1
lw $10, 0($12) # pr_rd, M -> M core1
ori $1, $0, 1 # bus_rdX & bus_wb, core1 M -> I

halt

# core 2
org 0x0200

li $10, 1
li $12, 8000

lw $13, 0($12) # pr_rd from I -> S core2
ori $1, $0, 1 # bus_rdX, core2 S -> I
ori $1, $0, 1 # nothing on bus, core2 stay in I
sw $10, 0($12) # pr_wr, I -> M core2

halt
