# Gili Gutfeld - 209284512

.section .rodata    #read only data section
intFormat:    	.string	"‫‪%d‬‬‬‬‬‬‬‬"
strFormat:    	.string	"‫‪%s‬‬‬‬‬‬‬‬"

    .text
    .globl	run_main
    .extern run_func
    .type	run_main, @function

# The function gets two pstrings and option number and calls the run_func function
    .type   main, @function

run_main:
    movq    %rsp, %rbp #for correct debugging
    
    # allocate memory
    pushq   %rbp
    movq    %rsp, %rbp
    subq    $528, %rsp  # Move the stack pointer to get memory for the arguments
    
    # initialize first pstring
    movq    $intFormat, %rdi	# the string is the first paramter passed to the scanf function.
    leaq    4(%rsp), %rsi        # Load address for the length of the string we will scan
    xor     %rax, %rax
    call    scanf       # getting the size of string from user
    movl    4(%rsp), %esi
    movb    %sil, 8(%rsp)   # p1.len = len
    
    # get the first string
    movq    $strFormat, %rdi	# the string is the first paramter passed to the scanf function.
    leaq    9(%rsp), %rsi        # Load address for the string we will scan
    xorl    %eax, %eax
    call    scanf		 # calling to printf after its arguments are passed
    
    # Put \0 in the end of the string
    movl    4(%rsp), %edi
    addq    %rsp, %rdi
    addq    $9, %rdi
    movq    $0, (%rdi)
    
    # initialize second pstring
    movq    $intFormat, %rdi	# the string is the first paramter passed to the scanf function.
    leaq    4(%rsp), %rsi        # Load address for the length of the string we will scan
    xorl    %eax, %eax
    call	   scanf		 # calling to printf after its arguments are passed
    movl    4(%rsp), %esi
    movb    %sil, 264(%rsp)   # p2.len = len
    
    # get the second string
    movq    $strFormat, %rdi	# the string is the first paramter passed to the scanf function.
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
    call    scanf		 # calling to printf after its arguments are passed
    
    # put the arguments in registers for calling to run_func
    movq    (%rsp), %rdi    # Put the option in the first argument
    leaq    8(%rsp), %rsi    # Put the first string in the second argument
    leaq    264(%rsp), %rdx    # Put the second string in the third argument
    call    run_func
    
    # done
    addq    $528, %rsp
    popq    %rbp
    xorl  %eax, %eax
    ret
    