li $10, 10
ori $11, $0, 0xFFFC
sw $10, 0($11)


halt
sw $10, 0x100($11)
