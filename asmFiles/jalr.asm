org 0x000
li $10, 20 // 0
li $11, 8 // 4

jalr $11, 0($10) // 8

li $12, 22 // 12
halt
li $12, 58 // 16
halt


