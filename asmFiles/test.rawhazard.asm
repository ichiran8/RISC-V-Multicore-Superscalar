org 0x000
ori $1, $0, 0x2
ori $4, $0, 0x100
sw $1, 0($4) 
lw $11, 0($4)
addi $10, $11, 1

sw $10, 100($0) 
halt

org 0x200
halt