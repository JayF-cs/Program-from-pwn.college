.intel_syntax noprefix
.global _start
_start:

.str_lower:
        xor rbx, rbx            #Get your loop iterator
        xor rdx, rdx
        test rdi, rdi           #Check if rdi is nullptr
        jz .finish              #If rdi is nullptr jump to finish


.loop:
        cmp byte ptr [rdi], 0
        je .finish

        cmp byte ptr [rdi], 0x5a
        jg .next

        mov rbx, rdi
        xor rdi, rdi
        mov dil, byte ptr [rbx]
        mov rax, 0x403000
        call rax
        mov byte ptr [rbx], al
        mov rdi, rbx
        inc rdx

.next:
        inc rdi
        jmp .loop

.finish:
        mov rax, rdx                    #Move iterator value into rax so it can be returned
        ret
