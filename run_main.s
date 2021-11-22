# Gili Gutfeld - 209284512

.section .rodata    #read only data section
strFormat:	.string	"%s"
intFormat:       .string "%d"

    .text
    .globl	run_main
    .type	run_main, @function

run_main:
    
    # allocate memory
    pushq   %rbp
    movq    %rsp, %rbp
    subq    $528, %rsp  # Move the stack pointer to get memory for the arguments
    
    # initialize first pstring
    movq    $intFormat, %rdi	# the string is the first paramter passed to the printf function.
    movq    %rsp, %rsi        # Load address for the length of the string we will scan
    xorq    %rax, %rax
    call    scanf       # getting the size of string from user
    movl    (%rsp), %esi
    movb    %sil, 8(%rsp)   # p1.len = len
    
    # get the first string
    movq    $strFormat, %rdi	# the string is the first paramter passed to the printf function.
    leaq    9(%rsp), %rsi        # Load address for the string we will scan
    xorq    %rax, %rax
    call    scanf		 # calling to printf after its arguments are passed
    
    # Put \0 in the end of the string
    movl    (%rsp), %edi
    addq    %rsp, %rdi
    addq    $9, %rdi
    movq    $0, (%rdi)
    
    # initialize second pstring
    movq    $intFormat, %rdi	# the string is the first paramter passed to the printf function.
    leaq    (%rsp), %rsi        # Load address for the length of the string we will scan
    xorq    %rax, %rax
    call	   scanf		 # calling to printf after its arguments are passed
    movl    (%rsp), %esi
    movb    %sil, 264(%rsp)   # p2.len = len
    
    # get the second string
    movq    $strFormat, %rdi	# the string is the first paramter passed to the printf function.
    leaq    265(%rsp), %rsi        # Load address for the string we will scan
    xorq    %rax, %rax
    call    scanf		 # calling to printf after its arguments are passed
    
    # Put \0 in the end of the string
    movl    (%rsp), %edi
    addq    %rsp, %rdi
    addq    $265, %rdi
    movq    $0, (%rdi)
   
    # get the option
    movq    $intFormat, %rdi	# the string is the first paramter passed to the printf function.
    leaq    (%rsp), %rsi        # Load option to which function to run
    xorq    %rax, %rax
    call    scanf		 # calling to printf after its arguments are passed
    
    # put the arguments in registers for calling to run_func
    movl    (%rsp), %edi        # Put the option in the first argument
    leaq    8(%rsp), %rsi    # Put the first string in the second argument
    leaq    264(%rsp), %rdx    # Put the first string in the second argument
    call    run_func
    
    # done
    movq    %rbp, %rsp
    popq    %rbp
    xorq    %rax, %rax
    ret
    
