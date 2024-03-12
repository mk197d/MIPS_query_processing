.data
numberList: .space 40000
queryList: .space 40000
L: .space 40000
R: .space 40000
k: .space 4
n: .space 4
q: .space 4
newline: .asciiz "\n"

.text

main:

    # Taking in the size of numberList
    li $v0, 5
    syscall
    move $t0, $v0
    li $t9, 0
    sw $t0, n($t9)

    # Taking in the values in the numberList
    move $s0, $t0
    move $s1, $s0
    jal takingInput

    # Sorting the numberList
    li $a0, 0
    li $t9, 0
    lw $a1, n($t9)
    sub $a1, $a1, 1
    jal mergeSort   

    # Taking in the size of queryList 
    li $v0, 5
    syscall
    move $t0, $v0
    sw $t0, q

    # Taking in the values in the queryList
    move $s0, $t0
    move $s1, $t0
    jal takingQueries

    # Printing the result for each query by binary search
    lw $s0, q($0)
    li $s1, 0
    jal Compute_output

    # Program Done
    li $v0, 10
    syscall


# Taking as input the list of numbers
takingInput:

    addi $sp, $sp, -4   # Making space for the return address on the stack
    sw $ra, 0($sp)  #Storing the return address on the stack

# s0 -> size of numberList
# s1 -> (s0 - s1 + 1) = Number of inputs taken 

    # Calculating the address where the next input is to be stored
    sub $t2, $s0, $s1
    sll $t2, $t2, 2

    # Taking input and storing at desired address
    li $v0, 5
    syscall
    move $t3, $v0
    sw $t3, numberList($t2)

    sub $s1, $s1, 1

    bgtz $s1, takingInput

    lw $ra, 0($sp)
    add $sp, $sp, 4
    jr $ra


# Taking as input the queries of the user
takingQueries:

    addi $sp, $sp, -4   # Making space for the return address on the stack
    sw $ra, 0($sp)  #Storing the return address on the stack

# s0 -> size of queryList
# s1 -> (s0 - s1 + 1) = Number of queries taken 

    # Calculating the address where the next query is to be stored
    sub $t2, $s0, $s1
    sll $t2, $t2, 2

    # Taking the query and storing at the desired address
    li $v0, 5
    syscall
    move $t3, $v0
    sw $t3, queryList($t2)

    sub $s1, $s1, 1

    bgtz $s1, takingQueries

    lw $ra, 0($sp)
    add $sp, $sp, 4
    jr $ra

####################################################################################################################
############################################# MERGE SORT ###########################################################
####################################################################################################################
merge:
# a0 -> left index
# a2 -> middle index
# a1 -> right index

    addi $sp, $sp, -24   # Making space for the return address and the left, right and middle indicies on the stack
    sw $ra, 0($sp)  # Storing the return address on the stack
    sw $a0, 4($sp)  # At sp + 4 left index is stored
    sw $a1, 8($sp)  # At sp + 8 right index is stored
    sw $a2, 12($sp) # At sp + 12 middle index is stored

    # Storing the two halves in two arrays L and R, and then merging them in the original array

    # Register t1 contains the size of the array L
    sub $t1, $a2, $a0
    addi $t1, $t1, 1

    # Register t2 contains the size of the array R
    sub $t2, $a1, $a2

    # Storing the sizes on the stack
    sw $t1, 16($sp) # At sp + 16 size of the left array is stored
    sw $t2, 20($sp) # At sp + 20 size of the right array is stored

    # Copying the left half of the array into L
    lw $a0, 4($sp)  # Register a0 contains the first index to be copied to L
    lw $a2, 16($sp) # Register a2 contains the size of L
    move $s3, $a2   # Register s3 just checks whether all elements are copied
    jal copyL

    # Register s6 contains the first index of numberList from where copying starts for R
    lw $s6, 12($sp)
    addi $s6, $s6, 1

    # Copying the left half of the array into R
    move $a0, $s6   # Register a0 contains the first index to be copied to R
    lw $a2, 20($sp) # Register a2 contains the size of R
    move $s3, $a2   # Register s3 just checks whether all elements are copied
    jal copyR

    # Merging back
    lw $s0, 4($sp)  # Left index in numberList of the sub-array
    lw $s5, 8($sp)  # Right index in numberList of the right-array
    lw $s1, 16($sp) # Size of L
    lw $s2, 20($sp) # Size of R
    li $s3, 0       # Counter for L
    li $s4, 0       # Counter for R
    jal merge_back

    # Return
    lw $ra, 0($sp)
    addi $sp, $sp, 24
    jr $ra
   

copyL:
# a0 -> numberList index from where the array starts
# a2 -> size of array L
# s3 -> (s2 - s3 + 1) = Number of elements copied

    addi $sp, $sp, -4   # Making space for the return address on the stack
    sw $ra, 0($sp)  #Storing the return address on the stack

copyL_iterate:
    beqz $s3, copyDoneL

    # Calculating the addresses of the source{t6} and destination{t2} of the data
    sub $t2, $a2, $s3 
    sll $t2, $t2, 2

    move $t6, $a0
    sll $t6, $t6, 2
    add $t6, $t6, $t2

    # Loading and copying the value
    lw $t3, numberList($t6)
    sw $t3, L($t2)

    sub $s3, $s3, 1    # Decrementing the value of s3
    bgtz $s3, copyL_iterate

    j copyDoneL

copyDoneL:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

copyR:
# a0 -> numberList index from where the array starts
# a2 -> size of array L
# s3 -> (s2 - s3 + 1) = Number of elements copied

    addi $sp, $sp, -4   # Making space for the return address on the stack
    sw $ra, 0($sp)  #Storing the return address on the stack

copyR_iterate:
    beqz $s3, copyDoneR

    # Calculating the addresses of the source{t6} and destination{t2} of the data
    sub $t2, $a2, $s3 
    sll $t2, $t2, 2

    move $t6, $a0
    sll $t6, $t6, 2
    add $t6, $t6, $t2

    # Loading and copying the value
    lw $t3, numberList($t6)
    sw $t3, R($t2)

    sub $s3, $s3, 1    # Decrementing the value of s3
    bgtz $s3, copyR_iterate

    j copyDoneR

copyDoneR:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

merge_back:
# s0 -> current index of numberList
# s1 -> size of L
# s2 -> size of R
# s3 -> current index in L
# s4 -> current index in R
# s5 -> right index of numberList

    addi $sp, $sp, -4   # Making space for the return address on the stack
    sw $ra, 0($sp)  #Storing the return address on the stack
    j merge_back_iterate

merge_back_iterate:

    # Checking if process merge_back is complete
    addi $t9, $s5, 1
    beq $s0, $t9, merge_back_done

    # Checking if L is completly traversed
    beq $s3, $s1, copy_remainingR

    # Checking if R is completly traversed
    beq $s4, $s2, copy_remainingL

    # Register t1 contains the index of the current value in L
    move $t1, $s3
    sll $t1, $t1, 2
    lw $t5, L($t1) # Register t5 contains the Lvalue

    # Register t2 contains the index of the current value in R
    move $t2, $s4
    sll $t2, $t2, 2
    lw $t6, R($t2) # Register t6 contains the Rvalue

# Comparing the Lvalue and Rvalue and putting it back in numberList

    # Arguments for succeeding code
    move $a1, $t5
    move $a2, $t6

    beq $t5, $t6, same_value    # If they have the same value

    slt $t7, $t5, $t6
    bgtz $t7, leftLess  # If Lvalue < Rvalue
    beqz $t7, rightLess # If Lvalue > Rvalue

same_value:
    # Register t1 contains the index of the data value which is to be 
    # merged in the numberList and t7 contains the value
    move $t1, $s3
    sll $t1, $t1, 2
    lw $t7, L($t1)

    # Register t0 contains the index of the numberList where value is to be merged
    move $t0, $s0
    sll $t0, $t0, 2
    sw $t7, numberList($t0)

    # Incrementing the indices
    addi $s0, $s0, 1
    addi $s3, $s3, 1

    j merge_back_iterate

leftLess:
    # Register t1 contains the index of the data value which is to be 
    # merged in the numberList and t7 contains the value
    move $t1, $s3
    sll $t1, $t1, 2
    lw $t7, L($t1)

    # Register t0 contains the index of the numberList where value is to be merged
    move $t0, $s0
    sll $t0, $t0, 2
    sw $t7, numberList($t0)

    # Incrementing the indices
    addi $s0, $s0, 1
    addi $s3, $s3, 1

    j merge_back_iterate

rightLess:
    # Register t2 contains the index of the data value which is to be 
    # merged in the numberList and t7 contains the value
    move $t2, $s4
    sll $t2, $t2, 2
    lw $t7, R($t2)

    # Register t0 contains the index the numberList where value is to be merged
    move $t0, $s0
    sll $t0, $t0, 2
    sw $t7, numberList($t0)

    # Incrementing the indices
    addi $s0, $s0, 1
    addi $s4, $s4, 1

    j merge_back_iterate

copy_remainingR:
# a0 -> Return address

    # Checking if all the remaining numbers are merged
    beq $s4, $s2, merge_back_iterate

    # Register t2 contains the index of the data value which is to be 
    # merged in the numberList and t7 contains the value
    move $t2, $s4
    sll $t2, $t2, 2
    lw $t7, R($t2)

    # Register t0 contains the index the numberList where value is to be merged
    move $t0, $s0
    sll $t0, $t0, 2
    sw $t7, numberList($t0)

    # Incrementing the indices
    addi $s0, $s0, 1
    addi $s4, $s4, 1

    j copy_remainingR

copy_remainingL: 
# a0 -> Return address

    # Checking if all the remaining elements are inserted
    beq $s3, $s1, merge_back_iterate
    # Register t1 contains the address of the data value which is to be 
    # merged in the numberList and t7 contains the value
    move $t1, $s3
    sll $t1, $t1, 2
    lw $t7, L($t1)

    # Register t0 contains the address in the numberList where value is to be merged
    move $t0, $s0
    sll $t0, $t0, 2
    sw $t7, numberList($t0)

    # Incrementing the indices
    addi $s0, $s0, 1
    addi $s3, $s3, 1

    j copy_remainingL
    
merge_back_done:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

mergeSort:
# a0 -> left index
# a1 -> right index

    addi $sp, $sp, -16   # Making space for the return address and the left, right and middle indicies on the stack
    sw $ra, 0($sp)  # Storing the return address on the stack
    sw $a0, 4($sp)  # At sp + 4 left index is stored
    sw $a1, 8($sp)  # At sp + 8 right index is stored

    # Calculating the middle value and storing it on the stack at sp + 12
    add $t3, $a0, $a1
    srl $t3, $t3, 1
    sw $t3, 12($sp) # At sp + 12 middle index is stored

    # If the array consists of only one element -> return
    beq $a1, $a0, mergeSort_done    

    # If the array consists of only two elements -> compare the two and merge
    addi $t8, $a0, 1
    move $a2, $a0
    beq $t8, $a1, merging

    # Sorting the left half of the array
    lw $a0, 4($sp)
    lw $a1, 12($sp)
    jal mergeSort

    # Sorting the right half of the array
    lw $a0, 12($sp)
    addi $a0, $a0, 1
    lw $a1, 8($sp)
    jal mergeSort

    j merging

merging:

    # Merging the two sorted halves
    lw $a0, 4($sp)
    lw $a1, 8($sp)
    lw $a2, 12($sp)
    jal merge
    j mergeSort_done

mergeSort_done:
    lw $ra, 0($sp)
    addi $sp, $sp, 16
    jr $ra

# **************************************************************************************************************** #

####################################################################################################################
############################################ BINARY SEARCH #########################################################
####################################################################################################################

Compute_output:

    beq $s0, $s1, END_PROGRAM   # Checking if all queries have been processed
    j query_loop

query_loop:

    move $t1, $s1           # Index of current query
    sll $t1, $t1, 2
    lw $t0, queryList($t1)  # Register t0 contains the query value
    li $s4, -1              # Register s0 contains the output for the query

    li $s5, 0       # s5 -> Lower index for binary search
    lw $s7, n($0)   # s7 -> Upper index for binary search
    addi $s7, $s7, -1
    
    j search_loop

search_loop:

    bgt $s5, $s7, computationDone   # If lower index == upper index -> search done

    # Register s6 stores the middle index
    sub $s6, $s7, $s5
    addi $s6, $s6, 1
    srl $s6, $s6, 1
    add $s6, $s5, $s6 

    # Register t5 contains the middle value
    move $t5, $s6
    sll $t5, $t5, 2
    lw $t5, numberList($t5)

    beq $t5, $t0, search_equal      # If middle value == key

    slt $t6, $t5, $t0
    bgtz $t6, search_less_than      # If middle value < key
    beqz $t6, search_greater_than   # If middle value > key

search_less_than:
    addi $s5, $s6, 1    # lower = middle + 1
    j search_loop

search_greater_than:
    addi $s7, $s6, -1   # upper = middle - 1
    j search_loop

search_equal:
    move $s4, $s6       # storing the result
    addi $s7, $s6, -1   # upper = middle - 1 {In case of repeated elements in numberList}
    j search_loop

computationDone:

    # Printing result
    li $v0, 1
    add $a0, $s4, $zero
    syscall
    
    # Printing newline
    li $v0, 4
    la $a0, newline
    syscall

    # Increasing counter for queryList
    addi $s1, $s1, 1
    j Compute_output

END_PROGRAM:
    li $v0, 10
    syscall

# **************************************************************************************************************** #


