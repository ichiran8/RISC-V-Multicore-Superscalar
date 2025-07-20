li $10, 5
lui $11, 0xFFFFF
li $12, 0
bgeu $10, $11, end
sw $11, 0x100($12)
halt
end:
    sw $10, 0x100($12)
    halt
org 0x200
halt
