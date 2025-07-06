#----------------------------------------------------------
# Core 1 Init
#----------------------------------------------------------
  org 0x0000    
  li      sp, 0xFFFC    # core 1 stack
  jal     mainc1        # core 1 main program
  halt

#----------------------------------------------------------
# Shared Lock Functions
#----------------------------------------------------------
# pass in an address to lock function in argument register 0
# returns when lock is available
lock:
acquire:
  lr.w    t0, (a0)              # load lock location
  bne     t0, zero, acquire     # wait on lock to be open
  li      t1, 1
  sc.w    t2, t1, (a0)
  bne     t2, zero, lock        # if sc.w failed, retry (In case of SC failure, rd gets written 1 (!= 0))
  ret

# pass in an address to unlock function in argument register 0
# returns after freeing lock
unlock:
  sw      zero, 0(a0)           # exclusive writer safe to clear the lock
  ret


#----------------------------------------------------------
# Shared Subroutine Functions
#----------------------------------------------------------

#REGISTERS
#ra $1 Return address
#sp $2 Stack pointer
#gp $3 Global pointer
#tp $4 Thread pointer
#t0-2 $5-7 temps
#s0/fp $8 Saved/frame pointer
#s1 $9 Saved register
#$a0-1 $10-11 Fn args/return values
#$a2-7 $12-17 Fn args
#$s2-11 $18-27 Saved registers
#$t3-6 $28-31 Temporaries

# USAGE random0 = crc(seed), random1 = crc(random0)
#       randomN = crc(randomN-1)
#------------------------------------------------------
# $a0 = crc32($a2)
crc32:
  lui $t1, 0x04C11
   ori $t1, $t1, 0x7B7
   addi $t1, $t1, 0x600
   or $t2, $0, $0
   ori $t3, $0, 32
 
l1:
  slt $t4, $t2, $t3
   beq $t4, $0, l2
 
  ori $t5, $0, 31
   srl $t4, $a2, $t5
   ori $t5, $0, 1
   sll $a2,$a2,$t5
   beq $t4, $0, l3
   xor $a2, $a2, $t1
 l3:
  addi $t2, $t2, 1
   j l1
l2:
  or $a0, $a2, $0
   jr $1


# a2 = a
# a3 = b
# a0 = result

#-max (a2=a,a3=b) returns a0=max(a,b)--------------
max:
  push  $1
   or    $a0, $0, $a2
   slt   $t0, $a2, $a3
   beq   $t0, $0, maxrtn
   or    $a0, $0, $a3
 maxrtn:
   pop   $1
   jr    $1
 #--------------------------------------------------

#-min (a0=a,a1=b) returns v0=min(a,b)--------------
min:
  push  $1
   or    $a0, $0, $a2
   slt   $t0, $a3, $a2
   beq   $t0, $0, minrtn
   or    $a0, $0, $a3
 minrtn:
   pop   $1
   jr    $1
 #--------------------------------------------------

# a2 = Numerator
# a3 = Denominator
# a0 = Quotient
# a1 = Remainder

#-divide(N=$a2,D=$a3) returns (Q=$a0,R=$a1)--------
divide:               # setup frame
  push  $1           # saved return address
   or    $a0, $0, $0   # Quotient v0=0
   or    $a1, $0, $a2  # Remainder t2=N=a0
   beq   $0, $a3, divrtn # test zero D
   slt   $t0, $a3, $0  # test neg D
   bne   $t0, $0, divdneg
   slt   $t0, $a2, $0  # test neg N
   bne   $t0, $0, divnneg
 divloop:
  slt   $t0, $a1, $a3 # while R >= D
   bne   $t0, $0, divrtn
   addi $a0, $a0, 1   # Q = Q + 1
   sub  $a1, $a1, $a3 # R = R - D
   j     divloop
divnneg:
  sub  $a2, $0, $a2  # negate N
   jal   divide        # call divide
  sub  $a0, $0, $a0  # negate Q
   beq   $a1, $0, divrtn
   addi $a0, $a0, -1  # return -Q-1
   j     divrtn
divdneg:
  sub  $a2, $0, $a3  # negate D
   jal   divide        # call divide
  sub  $a0, $0, $a0  # negate Q
 divrtn:
   pop $1
   jr  $1
#-divide--------------------------------------------

push_parallel:
  li t1, stack_location # load stack
  lw t0, 0(t1) # load address of stack pointer
  addi t0, t0, 4 # increment stack pointer
  sw a0, 0(t0) # store value at new stack pointer
  sw t0, 0(t1) # store new stack pointer
  ret

pop_parallel:
  li t1, stack_location # load stack
  lw t0, 0(t1) # load address of stack pointer
  lw a0, 0(t0) # get value at stack pointer
  sw zero, 0(t0) # zero out top stack element
  addi t0, t0, -4 # increment stack pointer (not local one)
  sw t0, 0(t1) # store new stack pointer
  ret
 


#----------------------------------------------------------
# Core 1 Main
#----------------------------------------------------------
# main function does something ugly but demonstrates beautifully
mainc1:
  push    ra                    # save return address to main

  addi s0, zero, seed # move seed address to s0
  lw s0, 0(s0) # move seed to s0

  addi s11, zero, 0 # start from index 0
  addi s10, zero, 256

  for_crc:
    bge s11, s10, exit_for_crc # i >= 256, generated all 256 numbers

    add a2, zero, s0  # move old seed to a2
    jal crc32 # get random[i] = crc(random[i - 1])
    
    add s0, a0, zero # move new seed to save reg


    ori     a0, zero, lock_var    # move lock to argument register
    jal     lock                  # try to acquire the lock

    # ----------------------- #
    # critical code segment:

    # here should we be syncronizing with other core, so both cores have crc
    add a0, s0, zero # move save reg to function arg

    jal push_parallel # put random[i] on stack

    # ----------------------- #

    ori     a0, zero, lock_var    # move lock to argument register
    jal     unlock                # release the lock

    addi s11, s11, 1 # increment index

    jal for_crc # go to next iteration


  exit_for_crc:

  pop     ra                    # get return address
  ret


#----------------------------------------------------------
# Core 2 Init
#----------------------------------------------------------
  org 0x0200               
  li      sp, 0x7FFC            # core 2 stack
  jal     mainc2                # core 2 main program
  halt

#----------------------------------------------------------
# Core 2 Main
#----------------------------------------------------------
# main function does something ugly but demonstrates beautifully
mainc2:
  push    ra                    # save return address

  addi s2, zero, 0 # count for average ; x18
  addi s3, zero, 0 # current max ; x19
  addi s4, zero, 2147483647 # current min (2^31 - 1) ; x20

  addi s10, zero, 0 # start from index 0
  addi s11, zero, 256

  for_consumer:
    bge s10, s11, exit_for_consumer # i >= 256, used all 256 numbers

    li s9, stack_location # load stack
    lw s8, 0(s9) # load address of stack pointer
    lw s7, 0(s8) # load value
    beq s7, zero, for_consumer
    # beq zero, zero, exit_for_consumer


    ori     a0, zero, lock_var    # move lock to argument register
    jal     lock                  # try to acquire the lock

    # ----------------------- #
    # critical code segment:


    jal pop_parallel # get random[i] on stack
    addi s1, a0, 0 # move popped value to s1

    # ----------------------- #

    ori     a0, zero, lock_var    # move lock to argument register
    jal     unlock                # release the lock

    slli s1, s1, 16 # use the lower 16 bits of value
    srli s1, s1, 16 # (zeroing out top 16 bits)

    add s2, s2, s1 # add value to current sum

    # can use their subroutines
    blt s1, s3, skip_max  # if value > curr max (there's no branch less/equal to)
    addi s3, s1, 0 # curr max = value
    skip_max:

    bgeu s1, s4, skip_min # if value < curr min
    addi s4, s1, 0 # curr min = value
    skip_min:
    
    addi s10, s10, 1 # increment index
    jal for_consumer # go to next iteration

  exit_for_consumer:

  addi a2, s2, 0 # move sum to a2
  addi a3, zero, 256 # move 256 to a3
  #jal divide # divide sum by 256
  srli a2, a2, 8
  addi a0, a2, 0
  #srli a3, a3, 8
  
  sw s3, 0x700(zero)
  sw s4, 0x704(zero)
  sw a0, 0x708(zero)

  #sw a0, 0x8000($0)
  pop   ra                    # get return address
  ret

#----------------------------------------------------------
# Shared Data Segment
#----------------------------------------------------------

org 0x0300
lock_var:
  cfw 0x0     # lock starts unlocked, should end unlocked
res:
  cfw 0x0     # end result should be 3
seed:
  cfw 0x8    # for crc generation

org 0x04000
stack_location:
  cfw stack_pointer     

org 0x05000
stack_pointer:
  cfw 0x0
