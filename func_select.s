# Gili Gutfeld - 209284512

.section .rodata    #read only data section

    format50:	.string	"‫‪first‬‬ ‫‪pstring‬‬ ‫‪length:‬‬ ‫‪%d,‬‬ ‫‪second‬‬ ‫‪pstring‬‬ ‫‪length:‬‬ ‫‪%d\n‬‬"
    format52:	.string	"‫‪‫‪old‬‬ ‫‪char:‬‬ ‫‪%c,‬‬ ‫‪new‬‬ ‫‪char:‬‬ ‫‪%c,‬‬ ‫‪first‬‬ ‫‪string:‬‬ ‫‪%s,‬‬ ‫‪second‬‬ ‫‪string:‬‬ ‫‪%s\n‬‬‬‬"
    format53:	.string	"‫‪‫‪length:‬‬ ‫‪%d,‬‬ ‫‪string:‬‬ ‫‪%s\n‬‬‬‬"
    format54:	.string	"‫‪length:‬‬ ‫‪%d,‬‬ ‫‪string:‬‬ ‫‪%s\n‬‬‬‬"
    format55:	.string	"‫‪‫‪compare‬‬ ‫‪result:‬‬ ‫‪%d\n‬‬‬‬‬‬"
    format0:    	.string	"‫‪invalid‬‬ ‫‪option!\n‬‬‬‬‬‬‬‬"
    format1:    	.string	"‫‪%c%c‬‬‬‬‬‬‬‬"
    intFormat:    	.string	"‫‪%d‬‬‬‬‬‬‬‬"
    int2Format:    	.string	"‫‪%d%d‬‬‬‬‬‬‬‬"
    strFormat:    	.string	"‫‪%s‬‬‬‬‬‬‬‬"

.align 8  # Align address to multiple of 8
.L10:
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
    .globl	run_func
    .extern pstrlen, replaceChar, pstrijcpy, swapCase, pstrijcmp
    .type	run_func, @function

# The function gets option and jumps to the right case
run_func:

    # Set up the jump table access
    leaq    -50(%rdi), %rcx        # Compute index = opt - 50
    movq    %rsi, %rdi
    movq    %rdx, %rsi
    cmpq    $10, %rcx                # Compare index:10
    ja .L9                      # if >10 goto default-case
    jmp *.L10(,%rsi,8)          # Goto jt[index]
    
    # Cases 50, 60
    .L1: # loc_A:
    
    pushq   %rsi
    
    call    pstrlen # call the length function with the first string
    popq    %rdi  # Put the second string in the first argument
    pushq   %rax  # Save the length of the first string on the stack
    
    call    pstrlen # call the length function with the second string
    movq    %rax, %rdx  # save the length of the second string
    popq    %rsi    #save the length of the first string
    
    movq    $format50, %rdi	# the string is the first paramter passed to the printf function.
    xorl    %eax, %eax
    call    printf		# calling to printf after its arguments are passed
    
    jmp .L7                   # Goto done
    
    # Case 52
    .L2: # loc_B:
    
    push    %rdi
    push    %rsi
    
    subq    $1, %rsp  # Move the stack pointer to get memory for the arguments
    
    # get the first char (the old char we want to replace)
    movq    $strFormat, %rdi	# the string is the first paramter passed to the scanf function.
    leaq    (%rsp), %rsi        # Load address for the first char
    xor     %rax, %rax
    call    scanf       # get the first char
    movzbl  (%rsp), %ebx # Put the char in callee saved register for later
    
    # get the first char (the new char we want to put)
    movq    $strFormat, %rdi	# the string is the first paramter passed to the scanf function.
    leaq    (%rsp), %rsi        # Load address for the second char
    xor     %rax, %rax
    call    scanf       # get the second char
    movzbl  (%rsp), %edx # Put the new char in the third argument
    
    popq    %rdi    # Put the first string in the first argument
    movb    %bl, %sil   # put the old char in the second argument
    
    # Save the chars in the stack to use it for the second string
    pushq   %rbx
    pushq   %rdx
    
    call    replaceChar
    
    # get from the stack the second string and the old and the new char
    popq    %rdx
    popq    %rbx
    popq    %rdi
    
    # save in the stack the replaced string, the old char and the new char
    pushq   %rax
    pushq   %rbx
    pushq   %rdx
    
    call    replaceChar
    
    # put all the arguments in the right registers and call printf
    movq    $format52, %rdi
    popq    %rsi
    popq    %rdx
    popq    %rcx
    movq    %rax, %r8
    call    printf
    
    jmp .L7                   # Goto done
    
    # Case 53
    .L3: # loc_C:
    
    pushq   %rsi
    pushq   %rdi
    
    subq    $16, %rsp  # Move the stack pointer to get memory for the arguments
    
    # get the nubmers i and j
    movq    $int2Format, %rdi	# the string is the first paramter passed to the scanf function.
    leaq    (%rsp), %rsi        # Load address for the first number
    leaq    8(%rsp), %rdx        # Load address for the first number
    xor     %rax, %rax
    call    scanf       # get the numbers
    
    # put the arguments in the registers to call the function
    popq    %rcx
    popq    %rdx
    popq    %rsi
    movq    (%rsp), %rdi
    call    pstrijcpy‬‬
    
    # put all the arguments in the right registers and call printf for the first string
    movq    $format53, %rdi
    movq    %rax, %rdx
    movb    (%rax), %sil
    call    printf
    
    # put all the arguments in the right registers and call printf for the second string
    movq    $format53, %rdi
    popq    %rdx
    movb    (%rdx), %sil
    call    printf
  
    jmp .L7                   # Goto done
    
    # Cases 54
    .L4: # loc_D:
    
    pushq   %rsi
    
    call    ‫‪swapCase‬‬ # call the length function with the first string
    popq    %rdi  # Put the second string in the first argument
    pushq   %rax  # Save the address of the first string
    
    call    pstrlen # call the length function with the second string
    popq    %rdx  # get the address of the first string
    pushq   %rax  # Save the address of the second string
    
    # print the first string
    movb    (%rdx), %sil    # put the length of the first string in the second argument
    movq    $format54, %rdi	# the string is the first paramter passed to the printf function.
    xorl    %eax, %eax
    call    printf
    
    # print the second string
    movq    $format54, %rdi	# the string is the first paramter passed to the printf function.
    popq    %rdx  # put the address of the second string in the third argument
    movb    (%rdx), %sil    # put the length of the second string in the second argument
    call    printf		# calling to printf after its arguments are passed
    
    jmp .L7                   # Goto done
    
    # Cases 55
    .L5: # loc_E:
    
    push    %rsi
    push    %rdi
    
    subq    $16, %rsp  # Move the stack pointer to get memory for the arguments
    
    # get the nubmers i and j
    movq    $int2Format, %rdi	# the string is the first paramter passed to the scanf function.
    leaq    (%rsp), %rsi        # Load address for the first number
    leaq    8(%rsp), %rdx        # Load address for the first number
    xor     %rax, %rax
    call    scanf       # get the numbers
    
    # put the arguments in the registers to call the function
    popq    %rcx
    popq    %rdx
    popq    %rsi
    popq    %rdi
    call    ‫‪pstrijcmp‬‬
    
    # put all the arguments in the right registers and call printf for the first string
    movq    $format55, %rdi
    movq    %rax, %rsi
    call    printf
    
    jmp .L7                   # Goto done          # Goto done
    
    # Default case
    .L9: # loc_def:
    call    printf                # print ‫‪invalid‬‬ ‪option
    # Return result
    .L7: # done:
    ret
    