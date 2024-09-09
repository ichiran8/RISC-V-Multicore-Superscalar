li $10, 5
li $11, 8
li $15, 0x8
jal $11, end

sw $11, 0x100($15)
halt

end:
    sw $10, 0x100($15)
    halt
