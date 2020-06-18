.p2align        4, 0x90
    .globl  _main         ## -- Begin function main
_main:                    ## @main
    mov  $1, %eax
    push    %rax
    movl $2,%eax
    pop     %eax
    add     %eax, %eax
    ret
