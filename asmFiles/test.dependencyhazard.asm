lui $8, 0xEEF
srli $8, $8, 12
add   $7, $8, $7

sw    $7, 100($0) # only this is causing error?
halt

org 0x200
halt