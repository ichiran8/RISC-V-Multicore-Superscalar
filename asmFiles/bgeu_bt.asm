lui $10, 0xFFFFF
li $11, 8
li $12, 0

bgeu $10, $11, end

sw $11, 0x100($12)
halt
end:
    sw $10, 0x100($12)
    halt
