.intel_syntax noprefix
.global _start
_start:

mov rbx, 0
mov rax, 0

cmp rdi, 0x0
je finish

loop:
        cmp BYTE PTR [rdi + rbx], 0
        je finish
        inc rax
        inc rbx
        jmp loop

finish:
