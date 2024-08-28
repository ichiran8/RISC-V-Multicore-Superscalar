lui $10, 0xFFFFF
li $11, 8

bgeu $10, $11, end

mv $12, $10

halt

end:
    mv $12, $11
    halt
