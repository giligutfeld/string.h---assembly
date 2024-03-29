.section  .rodata

    invalidInput:        .string "invalid input!\n"
    invalidOption:  .string "invalid option!\n"
    intFormat:      .string "%d"
    strFormat:      .string "%s"
    int2Format:     .string "‫‪%d %d‬‬‬‬‬‬‬‬"
    str2Format:    .string "%s%s"
    format50:	.string	"‫‪first‬‬ ‫‪pstring‬‬ ‫‪length:‬‬ ‫‪%d,‬‬ ‫‪second‬‬ ‫‪pstring‬‬ ‫‪length:‬‬ ‫‪%d\n‬‬"
    format52:	.string	"‫‪‫‪old‬‬ ‫‪char:‬‬ ‫‪%c,‬‬ ‫‪new‬‬ ‫‪char:‬‬ ‫‪%c,‬‬ ‫‪first‬‬ ‫‪string:‬‬ ‫‪%s,‬‬ ‫‪second‬‬ ‫‪string:‬‬ ‫‪%s\n‬‬‬‬"
    format53:	.string	"‫‪‫‪length:‬‬ ‫‪%d,‬‬ ‫‪string:‬‬ ‫‪%s\n‬‬‬‬"
    format54:	.string	"‫‪length:‬‬ ‫‪%d,‬‬ ‫‪string:‬‬ ‫‪%s\n‬‬‬‬"
    format55:	.string	"‫‪‫‪compare‬‬ ‫‪result:‬‬ ‫‪%d\n‬‬‬‬‬‬"
    format0:    	.string	"‫‪invalid‬‬ ‫‪option!\n‬‬‬‬‬‬‬‬"

.align 8  # Align address to multiple of 8
.JMP_TABLE:
.quad .L1 # Case 50: loc_A
.quad .L9 # Case 51: loc_def
.quad .L2 # Case 52: loc_B
.quad .L3 # Case 53: loc_C
.quad .L4 # Case 54: loc_D
.quad .L5 # Case 55: loc_E
.quad .L9 # Case 56: loc_def
.quad .L9 # Case 57: loc_def
.quad .L9 # Case 58: loc_def
.quad .L9 # Case 59: loc_def
.quad .L1 # Case 60: loc_A

    .text
    .globl	‫‪pstrlen, ‫‪replaceChar‬‬, pstrijcpy, ‫‪swapCase‬‬, ‫‪pstrijcmp‬‬, main, run_func
    
    .type	‫‪replaceChar‬‬, @function
    
replaceChar:  
    pushq   %rdi                    # Save *pstr
    movb    (%rdi), %cl             # Save the length of the string
    addq    $1, %rdi
    
    .WHILE:
    cmpb    (%rdi), %sil            # Check if the char is the old char we got
    jne .DIFFERENT
    movb    %dl, (%rdi)             # Replace the old char by the new char
    
    .DIFFERENT:
    addq    $1, %rdi                # Go to the next char in the string
    subq    $1, %rcx                # Substract 1 from the length
    cmpq    $0, %rcx                # Check when we checked all the string
    jne .WHILE                      # then return to the while
    popq    %rax
    ret
    
    .type	pstrijcpy, @function
    
pstrijcpy‬‬:
    pushq   %rdi                    # Save *dst
    
    # check i and j are valid input
    cmpb    %cl, (%rdi)             # Check j < len(src)
    jle .INVALID_INPUT
    cmpb    %cl, (%rsi)             # Check j < len(dst)
    jle .INVALID_INPUT
    
    addq    %rdx, %rdi              # Go to the index i in the first pstring
    addq    %rdx, %rsi              # Go to the index i in the second pstring
    addq    $1, %rcx
    
    .GO_NEXT:                       # Loop until we arrive to j
    addq    $1, %rdi
    addq    $1, %rsi
    movb    (%rsi), %al             # Save the char in the index of the src
    movb    %al, (%rdi)             # and copy it to the dest
    subq    $1, %rcx                # Do j-- until i will equal j
    cmpq    %rdx, %rcx              # Check if we arrived to j
    jne .GO_NEXT
    jmp .DONE
    
    .INVALID_INPUT:
    movq    $strFormat, %rdi
    movq    $invalidInput, %rsi
    xorl    %eax, %eax
    call    printf
    
    .DONE:
    popq    %rax
    ret

    .type	‫‪pstrijcmp‬‬, @function
    
‫‪pstrijcmp‬‬:
    # Check i and j are valid input
    cmpb    %cl, (%rdi)             # Check j < len(src)
    jle .INVALID_INPUT2
    cmpb    %cl, (%rsi)             # Check j < len(dst)
    jle .INVALID_INPUT2
    
    addq    %rdx, %rdi              # Go to the index i in the first pstring
    addq    %rdx, %rsi              # Go to the index i in the second pstring
    addq    $1, %rcx                # Start from j and not from j - 1
    
    .GO_NEXT3:                      # Loop until we arrive to j
    addq    $1, %rdi
    addq    $1, %rsi
    
    # Compare between the characters in the string in the same index
    movb    (%rsi), %al             # Save the char of the first string and compare it to the char in the second string
    cmpb    %al, (%rdi)             # and compare it to the char in the second string
    jl  .SMALLER
    cmpb    %al, (%rdi)
    jg  .GREATER
    subq    $1, %rcx                # Do j-- until i will equal j
    cmpq    %rdx, %rcx              # Check if we arrived to j
    je .EQUAL                       # then the strings are equal
    jmp .GO_NEXT3
    
    # The sub-strings are equal
    .EQUAL:
    movl    $0, %eax
    jmp .DONE2
    
    # The first sub-string is greater lexicographic
    .SMALLER:
    movl    $1, %eax
    jmp .DONE2
    
    # The second sub-string is greater lexicographic
    .GREATER:
    movl    $-1, %eax
    jmp .DONE2
       
    # The input is invalid
    .INVALID_INPUT2:
    movq    $strFormat, %rdi
    movq    $invalidInput, %rsi
    xorl    %eax, %eax
    call    printf
    movl    $-2, %eax
    
    .DONE2:
    ret

    .type	‫‪pstrlen‬‬, @function
    
# get *pstring and return its length
pstrlen:
    movzbl (%rdi), %eax
    ret
    
    .type	‫‪swapCase‬‬, @function
‫‪swapCase‬‬:
    pushq   %rdi                        # Save *pstr
    
    .GO_NEXT2:                          # Loop until we arrive to j
    addq    $1, %rdi
    
    cmpq    $0, (%rdi)                  # Check if we arrived to \0
    je .FINISH
    
    cmpb    $122, (%rdi)                # Check if the character is after 'z'
    jg .GO_NEXT2
    
    cmpb    $65, (%rdi)                 # Check if the character is before 'A'
    jl .GO_NEXT2
    
    cmpb    $97, (%rdi)                 # Check if the character is after 'a'
    jge .BOTTOM_CASE
    
    cmpb    $97, (%rdi)                 # Check if the character is before 'Z'
    jle .UPPER_CASE
    
    .BOTTOM_CASE:
    subb    $32, (%rdi)
    jmp .GO_NEXT2
    
    .UPPER_CASE:
    addb    $32, (%rdi)
    jmp .GO_NEXT2
    
    .FINISH:
    popq    %rax
    ret
    
    .type	run_func, @function

# The function gets option and jumps to the right case
run_func:

    # Set up the jump table access
    leaq    -50(%rdi), %rcx             # Compute index = opt - 50
    movq    %rsi, %rdi
    movq    %rdx, %rsi
    cmpq    $10, %rcx                   # Compare index:10
    ja .L9                              # if >10 goto default-case
    jmp *.JMP_TABLE(,%rcx,8)            # Goto jt[index]
    
    # Cases 50, 60
    .L1: # loc_A:
    
    pushq   %rsi
    
    call    pstrlen                     # call the length function with the first string
    popq    %rdi                        # Put the second string in the first argument
    pushq   %rax                        # Save the length of the first string on the stack
    
    call    pstrlen                     # call the length function with the second string
    movq    %rax, %rdx                  # save the length of the second string
    popq    %rsi                        #save the length of the first string
    
    movq    $format50, %rdi             # the string is the first paramter passed to the printf function.
    xorl    %eax, %eax
    call    printf                      # calling to printf after its arguments are passed
    
    jmp .L7                             # Goto done
    
    # Case 52
    .L2: # loc_B:
    
    pushq   %rdi
    pushq   %rsi
    
    subq    $8, %rsp                    # Move the stack pointer to get memory for the arguments
    
    # get the old char and the new char
    movq    $str2Format, %rdi           # the string is the first paramter passed to the scanf function.
    leaq    (%rsp), %rsi                # Load address for the first char
    leaq    4(%rsp), %rdx               # Load address for the second char
    xor     %rax, %rax
    call    scanf
    
    movzbl  (%rsp), %esi                # put the new char in the second argument
    movzbl  4(%rsp), %edx               # put the old char in the second argument
    addq    $8, %rsp                    # deallocate the memory
    popq    %rdi                        # put the first string in the first argument
    
    # Save the chars in the stack to use it for the second string
    pushq   %rsi
    pushq   %rdx
    
    call    replaceChar
    
    # get from the stack the second string and the old and the new char
    popq    %rdx
    popq    %rsi
    popq    %rdi
    
    # save in the stack the replaced string, the old char and the new char
    pushq   %rax
    pushq   %rsi
    pushq   %rdx
    
    call    replaceChar
    
    # put all the arguments in the right registers and call printf
    movq    $format52, %rdi
    popq    %rsi
    popq    %rdx
    popq    %rcx
    movq    %rax, %r8
    addq    $1, %rcx
    addq    $1, %r8
    
    # substarct 8 from %rsp to print the result (because it should be divided by 16) and add it back
    subq    $8, %rsp    
    call    printf
    addq    $8, %rsp
    
    jmp .L7                   # Goto done
    
    # Case 53
    .L3: # loc_C:
    
    pushq   %rdi
    pushq   %rsi
    
    subq    $8, %rsp                                # Move the stack pointer to get memory for the arguments
    
    # get the nubmer i
    movq    $intFormat, %rdi                        # the string is the first paramter passed to the scanf function.
    leaq    (%rsp), %rsi                            # Load address for the first number
    xor     %rax, %rax
    call    scanf                                   # get the numbers
    
    # get the nubmer j
    movq    $intFormat, %rdi                        # the string is the first paramter passed to the scanf function.
    leaq    4(%rsp), %rsi                           # Load address for the first number
    xor     %rax, %rax
    call    scanf                                   # get the numbers
    
    # put the arguments in the registers to call the function
    movl    (%rsp), %edx
    movl    4(%rsp), %ecx
    movq    8(%rsp), %rsi
    movq    16(%rsp), %rdi
    call    pstrijcpy‬‬
    
    addq    $8, %rsp                                # deallocate the memory from the stack
    
    # put all the arguments in the right registers and call printf for the first string
    movq    $format53, %rdi
    popq    %rdx
    movzbl  (%rdx), %esi
    addq    $1, %rdx
    call    printf
    
    # put all the arguments in the right registers and call printf for the first string
    movq    $format53, %rdi
    popq    %rdx
    movzbl  (%rdx), %esi
    addq    $1, %rdx
    
    # substarct 8 from %rsp to print the result (because it should be divided by 16) and add it back
    subq    $8, %rsp    
    call    printf
    addq    $8, %rsp
  
    jmp .L7                     # Goto done
    
    # Cases 54
    .L4: # loc_D:
    
    pushq   %rsi
    
    call    ‫‪swapCase                                    # call the length function with the first string
    popq    %rdi                                        # Put the second string in the first argument
    pushq   %rax                                        # Save the address of the first string
    
    call    ‫‪swapCase‬‬                                    # call the length function with the second string
    popq    %rdx                                        # get the address of the first string
    pushq   %rax                                        # Save the address of the second string
    
    # print the first string
    movzbl  (%rdx), %esi                                # put the length of the first string in the second argument
    addq    $1, %rdx                                    # go to the first character in the string
    movq    $format54, %rdi                             # the string is the first paramter passed to the printf function.
    xorl    %eax, %eax
    call    printf
    
    # print the second string
    movq    $format54, %rdi                             # the string is the first paramter passed to the printf function.
    popq    %rdx                                        # put the address of the second string in the third argument
    movzbl  (%rdx), %esi                                # put the length of the second string in the second argument
    addq    $1, %rdx                                    # go to the first character in the string
    
    # substarct 8 from %rsp to print the result (because it should be divided by 16) and add it back
    subq    $8, %rsp    
    call    printf
    addq    $8, %rsp
    
    jmp .L7                      # Goto done
    
    # Cases 55
    .L5: # loc_E:
    
    push    %rsi
    push    %rdi
    
    subq    $8, %rsp                                    # Move the stack pointer to get memory for the arguments
    
    # get the nubmer i
    movq    $intFormat, %rdi                            # the string is the first paramter passed to the scanf function.
    leaq    (%rsp), %rsi                                # Load address for the first number
    xor     %rax, %rax
    call    scanf                                       # get the numbers
    
    # get the nubmer j
    movq    $intFormat, %rdi                            # the string is the first paramter passed to the scanf function.
    leaq    4(%rsp), %rsi                               # Load address for the first number
    xor     %rax, %rax
    call    scanf                                       # get the numbers
    
    # put the arguments in the registers to call the function
    movl    (%rsp), %edx
    movl    4(%rsp), %ecx
    movq    8(%rsp), %rsi
    movq    16(%rsp), %rdi
    call    ‫‪pstrijcmp‬‬
    
    addq    $24, %rsp                                   # deallocate the memory from the stack
    
    # put all the arguments in the right registers and call printf for the first string
    movq    $format55, %rdi
    movq    %rax, %rsi
    
    # substarct 8 from %rsp to print the result (because it should be divided by 16) and add it back
    subq    $8, %rsp    
    call    printf
    addq    $8, %rsp
    
    jmp .L7                   # Goto done          
    
    # Default case
    .L9: # loc_def:
    
    movq    $invalidOption, %rdi
    xorl    %eax, %eax
    call    printf
    
    # Return result
    .L7: # done:
    ret
    
    .type   main, @function
main:
    movq    %rsp, %rbp #for correct debugging
    
    # allocate memory
    pushq   %rbp
    movq    %rsp, %rbp
    subq    $528, %rsp  # Move the stack pointer to get memory for the arguments
    
    # initialize first pstring
    movq    $intFormat, %rdi	# the string is the first paramter passed to the printf function.
    leaq    4(%rsp), %rsi        # Load address for the length of the string we will scan
    xor     %rax, %rax
    call    scanf       # getting the size of string from user
    movl    4(%rsp), %esi
    movb    %sil, 8(%rsp)   # p1.len = len
    
    # get the first string
    movq    $strFormat, %rdi	# the string is the first paramter passed to the printf function.
    leaq    9(%rsp), %rsi        # Load address for the string we will scan
    xorl    %eax, %eax
    call    scanf		 # calling to printf after its arguments are passed
    
    # Put \0 in the end of the string
    movl    4(%rsp), %edi
    addq    %rsp, %rdi
    addq    $9, %rdi
    movq    $0, (%rdi)
    
    # initialize second pstring
    movq    $intFormat, %rdi	# the string is the first paramter passed to the printf function.
    leaq    4(%rsp), %rsi        # Load address for the length of the string we will scan
    xorl    %eax, %eax
    call	   scanf		 # calling to printf after its arguments are passed
    movl    4(%rsp), %esi
    movb    %sil, 264(%rsp)   # p2.len = len
    
    # get the second string
    movq    $strFormat, %rdi	# the string is the first paramter passed to the printf function.
    leaq    265(%rsp), %rsi        # Load address for the string we will scan
    xorl    %eax, %eax
    call    scanf		 # calling to printf after its arguments are passed
    
    # Put \0 in the end of the string
    movl    4(%rsp), %edi
    addq    %rsp, %rdi
    addq    $265, %rdi
    movq    $0, (%rdi)
   
    # get the option
    movq    $intFormat, %rdi	# the string is the first paramter passed to the printf function.
    leaq    (%rsp), %rsi        # Load option to which function to run
    xorl    %eax, %eax
    call    scanf		 # calling to printf after its arguments are passed
    
    # put the arguments in registers for calling to run_func
    movl    (%rsp), %edi        # Put the option in the first argument
    leaq    8(%rsp), %rsi    # Put the first string in the second argument
    leaq    264(%rsp), %rdx    # Put the first string in the second argument
    call    run_func
    
    # done
    addq    $528, %rsp
    popq    %rbp
    xorl  %eax, %eax
    ret
    