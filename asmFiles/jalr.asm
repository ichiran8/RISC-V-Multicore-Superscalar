org 0x000
li $10, 16 // 0
li $11, 8 // 4

li $15, 8

jalr $11, 0($10) // 12

sw $12, 0x100($15) // 16
halt
sw $10, 0x100($15) // 20
halt



org 0x200
halt