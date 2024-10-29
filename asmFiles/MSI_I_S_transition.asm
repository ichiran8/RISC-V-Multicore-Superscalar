org 0x000

li $10, 1
li $12, 8000

lw $13, 0($12) # pr_rd, I -> S core1
ori $1, $0, 1 # bus_rd, S -> S core1

halt

org 0x0200

li $10, 1
li $12, 8000

ori $1, $0, 1 # bus_rd, stay in I core2
lw $13, 0($12) # pr_rd from I -> S from core2

halt
