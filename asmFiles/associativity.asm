org 0x000

li $10, 1
li $11, 2
li $12, 8

li $14, 5
li $15, 76

sw $10, 0($12)
sw $11, 4($12)

sw $14, 0($15) # different tag and same index

lw $13, 0($12)

halt
