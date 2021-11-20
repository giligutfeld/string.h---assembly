# Gili Gutfeld - 209284512

.section  .rodata

strFormat: .string "%s\n"
invalidInput: .string "invalid input!\n"

    .text
    .globl	‫‪pstrlen, pstrijcpy, ‫‪replaceChar‬‬, ‫‪swapCase‬‬, ‫‪pstrijcmp‬‬

####################################################################
    
    .type	‫‪pstrlen‬‬, @function
# get *pstring and return its length
pstrlen:

    movzbl (%rdi), %eax
    ret

####################################################################
    
    .type	‫‪replaceChar‬‬, @function
    
    # get *pstring and two chars, replace the old one chars by the new one in the string
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
    
####################################################################
    
    .type	pstrijcpy, @function
    
    # get two *pstrings and two chars and copy the first string to the second string between the indexes we got
pstrijcpy:

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
    
####################################################################
    
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
    
####################################################################

    .type	‫‪pstrijcmp‬‬, @function
    
    # get two *pstrings and two chars and check who is greater lexicographic from the first string and the second string between the indexes we got
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
    