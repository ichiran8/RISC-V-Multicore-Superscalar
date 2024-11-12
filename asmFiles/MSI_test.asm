org 0x000

li $10, 1
li $12, 8000

lw $13, 0($12) # pr_rd, I -> S core1
lw $13, 0($12) # pr_rd, S -> S core1

halt

org 0x0200

li $10, 1
li $12, 8000

lw $13, 0($12) # pr_rd, I -> S core1
sw $13, 0($12) # pr_rd from S -> M from core2

halt
