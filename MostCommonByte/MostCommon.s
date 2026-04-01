.intel_syntax noprefix
.global _start
_start:

.most_common_byte:

	push rbp		#Create array
	mov rbp, rsp	#Move rbp to start of array
	sub rsp, 512	#Shift stack pointer to after the array
	xor rax, rax	#Return val
	xor rbx, rbx	#Iteratror

	.loop:
		cmp rbx, rsi
		jg .end
		xor rcx, rcx
		mov cl, [rdi + rbx]
		shl rcx, 1
		neg rcx
		inc WORD PTR [rbp + rcx]
		inc rbx
		jmp .loop

	.end:
		xor rbx, rbx	#iterator
		xor rdx, rdx	#max frequency
		xor rax, rax	#max frequency byte

	.loopB:
		cmp rbx, 256
		jge .return
		xor rcx, rcx
		mov rcx,rbx
		shl rcx, 1
		neg rcx
		cmp WORD PTR [rbp + rcx], dx
		jle .continue
		mov dx, [rbp + rcx]
		mov rax, rbx
		jmp .continue

		.continue:
			inc rbx
			jmp .loopB

	.return:
		mov rsp, rbp
		pop rbp
		ret
