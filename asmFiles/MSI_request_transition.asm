org 0x000

li $10, 1
li $11, 2
li $12, 8

lw $13, 0($12) # read miss, I -> S
lw $13, 1($12) # read hit, S -> S
sw $11, 0($12) # write hit, S -> M
sw $10, 1($12) # write hit, M -> M
lw $9, 1($12) # read hit, M -> M

lw $13, 2($12) # write miss (different block), I -> M

halt
