li $10, 5
li $11, 8
sw $10, 0x100($11)
lw $12, 0x100($12)
add $12, $12, $11
halt

org 0x200
halt