#
# CS64 Spring 2013 
# Lab2
#    names: Eric Brunnet & Hans Marasigan
#    perm:
#    email:
#    date:

#lab02 tic tac toe
#
#    $s0 = current turn ( 1 for X and 2 for O ) 
#    $s1 = which one is the human ( 1 for X and 2 for O ) 
#    $s2 = next move of the current player
#    $s3 = the address of the status of the T-T-T board.
#
################
# Data segment #
################


    .data
grid:       .word 0 1 2 1 2 0 2 0 1 0   #array of the spaces of the board.

count:      .word 9                     #number of elements in the array
endl:       .asciiz "\n" 

draw:       .asciiz "draw"
win:        .asciiz "you win"
lose:       .asciiz "you lose"

choice:     .asciiz "Would you like to be X or O ?"

x:          .asciiz "X "
o:          .asciiz "O "
empty:      .asciiz "- " 
selectx:    .asciiz "User X please select the next square (1-9)"
selecto:    .asciiz "User O please select the next square (1-9)"
badmove:    .asciiz "Invalid move! the square is already occupied! please select again(1-9)"

    

 
################
# Text Segment #
################

    .text

main:       la $s3, grid                #places a[] address in $s3
            add $t0, $s3, $0            #places a[] address in $t0
            
            add $a0, $s3, $0
            jal printBoard
            j finishgame
            
    
printBoard: addi $t0, $s3, 36           #get address of "a[9]" (first element out of bounds)
            beq $a0, $t0, return        #a[9] -> return
            
            lw $t1, 0($a0)              #load a[i]
            add $t2, $0, $0             #$t2 = 0
            beq $t2, $t1, printempty    #a[i] = 0 -> branch to printempty
            addi $t2, $t2, 1            #X
            beq $t2, $t1, printx        #else a[i] = X -> branch to printx
            j printo                    #else branch to printo
            
next:       addi $a0, $a0, 4            #i++
            addi $sp, $sp, -4           #make space on stack
            sw $ra, 0($sp)              #save $ra
            jal printBoard              #printBoard(&a[i])
            lw $ra, 0($sp)              #restore $ra
            addi $sp, $sp, 4            #restore stack
return:     jr $ra                      #return                

printx:     addi $sp, $sp, -4           #make room on stack
            sw $a0, 0($sp)              #save $a0
            la $a0, x                   #set output to 'X' 
            li $v0, 4                   #set syscall for print
            syscall                     #print 'X'
            lw $a0, 0($sp)              #restore argument
            addi $sp, $sp, 4            #restore stack
            div $a0, $s3                #$HI = offset of a[i] from a[0]
            mfhi $t1                    #$t1 = $HI
            addi $t0, $0, 3             #$t0 = 3
            div $t1, $t0                #$HI = i % 3
            mfhi $t1                    #$t1 = $HI
            addi $t0, $0, 2             #$to = 2
            beq $t1, $t0, printNL       #print newline if 3 elements printed
            j next
            
printempty: addi $sp, $sp, -4           #make room on stack
            sw $a0, 0($sp)              #save $a0
            la $a0, empty               #set output to '-' 
            li $v0, 4                   #set syscall for print
            syscall                     #print '-'
            lw $a0, 0($sp)              #restore argument
            addi $sp, $sp, 4            #restore stack
            div $a0, $s3                #$HI = offset of a[i] from a[0]
            mfhi $t1                    #$t1 = $HI
            addi $t2, $0, 4             #$t2 = 4
            div $t1, $t2                #$LO = $t1/$t2
            mflo $t1                    #$t1 = i
            addi $t0, $0, 3             #$t0 = 3
            div $t1, $t0                #$HI = i % 3
            mfhi $t1                    #$t1 = $HI
            addi $t0, $0, 2             #$to = 2
            beq $t1, $t0, printNL       #print newline if 3 elements printed
            j next

printo:     addi $sp, $sp, -4           #make room on stack
            sw $a0, 0($sp)              #save $a0
            la $a0, o                   #set output to 'O' 
            li $v0, 4                   #set syscall for print
            syscall                     #print 'O'
            lw $a0, 0($sp)              #restore argument
            addi $sp, $sp, 4            #restore stack
            div $a0, $s3                #$HI = offset of a[i] from a[0]
            mfhi $t1                    #$t1 = $HI
            addi $t0, $0, 3             #$t0 = 3
            div $t1, $t0                #$HI = i % 3
            mfhi $t1                    #$t1 = $HI
            addi $t0, $0, 2             #$to = 2
            beq $t1, $t0, printNL       #print newline if 3 elements printed
            j next
            
printNL:    addi $sp, $sp, -4           #make room on stack
            sw $a0, 0($sp)              #save $a0
            la $a0, endl                #set output to '\n' 
            li $v0, 4                   #set syscall for print
            syscall                     #print 'X'
            lw $a0, 0($sp)              #restore argument
            addi $sp, $sp, 4            #restore stack                    #print 'X'
            j next
            
finishgame: li $v0,10                   #set syscall for program termination
            syscall                     #terminate
