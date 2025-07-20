li $10, 5

ori $11, $0, 0x100

sw $10, 0($11)
halt
org 0xFFFC

org 0x200
halt