org 0x000

li $10, 10
li $11, 11

auipc $10, 0xFFFFF7

sw $11, 0($10)
lw $11, 0($10)

halt
