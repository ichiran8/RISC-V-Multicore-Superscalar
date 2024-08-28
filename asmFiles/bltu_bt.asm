li $10, 5
lui $11, 0xFFFFF

bltu $10, $11, end

mv $12, $10

halt

end:
    mv $12, $11
    halt
