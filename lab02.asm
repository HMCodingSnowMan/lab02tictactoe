#
# CS64 Spring 2013 
# Lab2
#    names: Eric Brunnet & Hans Marasigan
#    perm: 4079877 & 5862230
#    email: eric_brunnett@umail.ucsb.edu & hansmarasigan@umail.ucsb.edu
#    date: 5/7/13

#lab02 tic tac toe
#
#    $s0 = current turn ( 1 for X and 2 for O ) 
#    $s1 = which one is the human ( 1 for X and 2 for O ) 
#    $s2 = next move of the current player
#    $s3 = the address of the status of the T-T-T board.
#
#    $s4 = number of valid turns
#    $s5 = which one is the comp
################
# Data segment #
################


    .data
grid:       .word 0 0 0 0 0 0 0 0 0 0   #array of the spaces of the board.

count:      .word 9                     #number of elements in the array
endl:       .asciiz "\n" 

draw:       .asciiz "DRAW!\n"
win:        .asciiz "You Win!\n"
lose:       .asciiz "You Lose!\n"

choice:     .asciiz "Would you like to be X or O? "

x:          .asciiz "X "
o:          .asciiz "O "
empty:      .asciiz "- " 
selectx:    .asciiz "User X please select the next square (1-9): "
selecto:    .asciiz "User O please select the next square (1-9): "
badmove:    .asciiz "Invalid move! the square is already occupied! please select again(1-9): "
offboard:   .asciiz "Invalid move! Please select again(1-9): "
newgame:    .asciiz "Would you like to play again (y/n)? "    

 
################
# Text Segment #
################

    .text

main:       la $s3, grid                #places a[] address in $s3
            add $s4, $0, $0             #num moves = 0

game:       la $a0, choice              #sets choice string into the output
            li $v0, 4                   #sets the print function
            syscall                     #prints the choice string

            li $v0, 12                  #sets the read function 
            syscall                     #reads the character
    		add $t1, $0, $v0            #store answer
			la $a0, endl                #sets endl string into the output
            li $v0, 4                   #sets the print function
            syscall                     #prints new line
			addi $t0, $0, 'o'           #$t0 = 'o'
			beq $t1, $t0, compstart     #branch if user selected o's
			addi $t0, $0, 'O'           #$t0 = 'O'
			beq $t1, $t0, compstart     #branch if user selected O's
			
			addi $s1, $0, 1             #set $s1, user choice, to 1, X's
			addi $s5, $0, 2             #set $s1, comp choice, to 2, O's


pmove:      add $s0, $s1, $0            #set $s0 to X's or O's turn 
            addi $t0,$0,9               #$t0 = 9
            beq $s4,$t0, finishgame     #if 9 moves made then exit
            add $a0, $s3, $0            #set argument for printBoard 
            jal printBoard              #printBoard(&a[0])
            addi $t0, $0, 1             #$t0 = 1
            bne $t0, $s1, Oprompt       #branch to O prompt if player is 0 
            la $a0, selectx             #prompts user to make a move
            li $v0, 4                   #sets the print
            syscall                     #prints
            j check

Oprompt:    la $a0, selecto             #prompts user to make a move
            li $v0, 4                   #sets the print
            syscall                     #prints

check:      li $v0, 5                   #sets the read
            syscall                     #reads
            addi $t0,$v0, -9            #$t0 = user choice - 9
            bgtz $t0, invalid           #branch if user choice is > 9
            addi $t0,$v0, -1            #$t0 = index value of user choice
            bltz $t0, invalid           #branch if user choice is < 1

            sll $t0,$t0,2               #sets offset (muti 4)
            add $t0,$s3,$t0             #adds offset to base address
            
            lw $t1,0($t0)               #loads word A[i] at address

            bne $t1, $0, illegal        #checks if A[i] is empty
            add $t1, $0, $s1            #sets A[i] to player's symbol
            sw $t1,0($t0)               #stores move onto board
            addi $s4, $s4, 1            #increment number of moves
            
            addi $t0,$0,9               #$t0 = 9
            beq $s4,$t0, finishgame     #if 9 moves made then exit
			j compbegin

            ### end player move ###

compstart:  addi $s1, $0, 2             #set $s1, user choice, to 2, O's
            addi $s5, $0, 1             #set $s1, comp choice, to 1, X's
compbegin:  add $s0, $s5, $0            #set whose turn it is
            add $s2,$s3,$0              #setting $s2 to a[0]
compcheck:  lw $t0,0($s2)               #load a[i]
            beq $t0, $0, compmove       #check if empty
            addi $s2,$s2,4              #increment position
            j compcheck                 #jump to compcheck

compmove:   addi $t0, $0, 1             #set $t0 to X
            bne $t0, $s1, compX         #if player is not X comp is X
            addi $t0, $0, 2             #empty slot found, set to O
            sw $t0, 0($s2)              #save to array
            addi $s4, $s4, 1            #increment num moves
            j pmove                     #jump to player move
            
compX:      addi $t0, $0, 1             #set $t0 to O
            sw $t0, 0($s2)              #save move
            addi $s4, $s4, 1            #increment num moves
            j pmove                     #jump to player move

invalid:    la $a0, offboard            #set out put to offboard            
            li $v0, 4                   #set syscall to print
            syscall                     #print
            j check                     #jump to check
            
illegal:    la $a0, badmove             #set out put to badmove            
            li $v0, 4                   #set syscall to print
            syscall                     #print
            j check                     #jump to check            
    
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
            addi $sp, $sp, 4            #restore stack
            j next
            
initialize:	add $s4, $0, $0
            add $t0, $0, $0             #re-initialize array to empty
            sw $t0, 0($s3)
            sw $t0, 4($s3)
            sw $t0, 8($s3)
            sw $t0, 12($s3)
            sw $t0, 16($s3)
            sw $t0, 20($s3)
            sw $t0, 24($s3)
            sw $t0, 28($s3)
            sw $t0, 32($s3)

            j game			
			
finishgame: add $a0, $s3, $0
            jal printBoard
			
			la $a0, draw
			li $v0, 4
			syscall
			
			la $a0, newgame
			li $v0, 4
			syscall
			
			li $v0, 12
			syscall
			add $t1, $0, $v0            #store answer
			la $a0, endl                #sets endl string into the output
            li $v0, 4                   #sets the print function
            syscall                     #prints new line
			addi $t0, $0, 'y'
			beq $t1, $t0, initialize
			addi $t0, $0, 'Y'
			beq $t1, $t0, initialize
			
            li $v0,10                   #set syscall for program termination
            syscall                     #terminate
