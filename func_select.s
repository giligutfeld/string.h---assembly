# Gili Gutfeld - 209284512

.section .rodata    #read only data section

.align 8  # Align address to multiple of 8

    format50:         .string "first pstring length: %d, second pstring length: %d\n"
    format52:         .string "old char: %c, new char: %c, first string: %s, second string: %s\n"
    format53:         .string "length: %d, string: %s\n"
    format54:         .string "length: %d, string: %s\n"
    format55:         .string "compare result: %d\n"
    format1:        .string	"‫‪%c%c‬‬‬‬‬‬‬‬"
    intFormat:      .string "%d"
    int2Format:     .string	"‫‪%d%d‬‬‬‬‬‬‬‬"
    strFormat:      .string	"‫‪%s‬‬‬‬‬‬‬‬"
    str2Format:      .string "%s%s"
    invalidOption:  .string         "invalid option!\n"


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
    .global run_func
    .type run_func, @function
run_func:
# The function gets option and jumps to the right case

    pushq   %rbp
    movq    %rsp, %rbp

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
    
    pushq   %rsi
    pushq   %rdi
    
    subq    $16, %rsp                    # Move the stack pointer to get memory for the arguments
    
    # get the old char and the new char
    movq    $str2Format, %rdi           # the string is the first paramter passed to the scanf function.
    leaq    (%rsp), %rsi                # Load address for the first char
    leaq    4(%rsp), %rdx               # Load address for the second char
    xor     %rax, %rax
    call    scanf
    
    movzbl  (%rsp), %esi                # put the new char in the second argument
    movzbl  4(%rsp), %edx               # put the old char in the second argument
    addq    $16, %rsp                    # deallocate the memory
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
    popq    %rdx
    popq    %rsi
    popq    %rcx
    movq    %rax, %r8
    addq    $1, %rcx
    addq    $1, %r8
    
    # substarct 8 from %rsp to print the result (because it should be divided by 16) and add it back
    call    printf
    
    jmp .L7                   # Goto done
    
    # Case 53
.L3: # loc_C:
    
    pushq   %rsi
    pushq   %rdi
    
    subq    $16, %rsp                                # Move the stack pointer to get memory for the arguments
    
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
    movq    24(%rsp), %rsi
    movq    16(%rsp), %rdi
    call    pstrijcpy
    
    addq    $16, %rsp                                # deallocate the memory from the stack
    
    # put all the arguments in the right registers and call printf for the first string
    movq    $format53, %rdi
    popq    %rdx
    movzbl  (%rdx), %esi
    addq    $1, %rdx
    subq    $8, %rsp    
    call    printf
    addq    $8, %rsp    
    
    # put all the arguments in the right registers and call printf for the first string
    movq    $format53, %rdi
    popq    %rdx
    movzbl  (%rdx), %esi
    addq    $1, %rdx
    
    # substarct 8 from %rsp to print the result (because it should be divided by 16) and add it back
    call    printf
  
    jmp .L7                     # Goto done
    
    # Cases 54
.L4: # loc_D:
    
    pushq   %rsi
    
    call    swapCase                                    # call the length function with the first string
    popq    %rdi                                        # Put the second string in the first argument
    pushq   %rax                                        # Save the address of the first string
    
    call    swapCase                                    # call the length function with the second string
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
    call    printf
    
    jmp .L7                      # Goto done
    
    # Cases 55
.L5: # loc_E:
    
    push    %rdi
    push    %rsi
    
    subq    $16, %rsp                                    # Move the stack pointer to get memory for the arguments
    
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
    movq    16(%rsp), %rsi
    movq    24(%rsp), %rdi
    call    pstrijcmp
    
    addq    $32, %rsp                                   # deallocate the memory from the stack
    
    # put all the arguments in the right registers and call printf for the first string
    movq    $format55, %rdi
    movq    %rax, %rsi
    
    # substarct 8 from %rsp to print the result (because it should be divided by 16) and add it back
    call    printf
    
    jmp .L7                   # Goto done         
    
    # Default case
.L9: # loc_def:
    
    movq    $invalidOption, %rdi
    xorl    %eax, %eax
    call    printf
    
    # Return result
.L7: # done:
    movq    %rbp, %rsp
    popq    %rbp
    ret
    
