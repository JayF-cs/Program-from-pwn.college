.intel_syntax noprefix
.global _start

.section .data
response:
    .ascii "HTTP/1.0 200 OK\r\n\r\n"
response_len = . - response

.section .text

_start:

#Setting up socket function call
mov rdi, 2 #AF_INET
mov rsi, 1 #SOCK_STREAM (TCP)
mov rdx, 0 #IPPROTO_IP
mov rax, 41 #Socket syscall val
syscall

#Setting up Bind
sub rsp, 16 #Reserve space for the sockaddr_in struct
mov WORD PTR [rsp], 2 #Set AF_INET
mov WORD PTR [rsp + 2], 0x5000 #Set port in big endian <--- Must be in big endian
mov DWORD PTR [rsp + 4], 0

mov rdi, rax #Set rdi register to fd returned from socket
mov rsi, rsp #Set rsi register to the address for the beginning of the struct
mov rdx, 16 #addrlen is the length of the struct which for this is always 16

mov rbx, rax #Put file descriptor in new register before writing over rax

mov rax, 49 #Set rax to bind syscall
syscall

#Setting up Listen
mov rdi, rbx #Put file descriptor for function call
mov rsi, 0 #
mov rax, 50 #Copy Listen syscall value into rax
syscall


.accept_loop:
#Setting up Accept
	mov rdi, rbx #Put file descriptor for function call
	mov rsi, 0 #NULL
	mov rdx, 0 #NULL
	mov rax, 43 #Copy Accept syscall val into rax
	syscall

	#Save new file descriptor before rax is overwritten
	mov r12, rax

	#Fork process
    mov rax, 57
    syscall
	cmp rax, 0

	#If equal to zero jump to childGet
	je .childGet
	
	.parent:
    	#Close socket
        mov rdi, r12
        mov rax, 3
        syscall

        #Restart loop
        jmp .accept_loop


	.childGet:
		#close socket
		mov rdi, rbx
		mov rax, 3
		syscall
	
		#Read request
		mov rdi, r12 #Client fd
		sub rsp, 0x1000 #Buffer for reading
		mov rsi, rsp #Make the buffer address a function arguement
		mov rdx, 0x1000 #Make size of buffer and arguement
		mov rax, 0
		syscall

		cmp BYTE PTR [rsp], 'P'
		je .childPost

		#Parseing Get path from http header
		mov rcx, 4 #Start rcx at 4 after "GET "
		.loop:
		    cmp BYTE PTR [rsp + rcx], 0x20
		    je .spaceHandle
		    inc rcx             
		    jmp .loop
		    
		.spaceHandle:
		    mov BYTE PTR [rsp + rcx], 0x00


		#Open file
		lea rdi, [rsp + 4]
		mov rsi, 0 #Read only
		mov rdx, 0 #Not using mode
		mov rax, 2
		syscall

		mov r13, rax

		#Read file second time
		mov rdi, r13
		sub rsp, 0x100
		mov rsi, rsp
		mov rdx, 0x100
		mov rax, 0
		syscall

		#Put size in r14
		mov r14, rax

		#Close open file
		mov rdi, r13
		mov rax, 3
		syscall

		#Writing HTTP Header
		mov rdi, r12
		lea rsi, [rip + response]
		mov rdx, response_len
		mov rax, 1
		syscall

		#Setting up http write
		mov rdi, r12 #Put client file descriptor in rdi
		mov rsi, rsp #Put address of response in rsi
		mov rdx, r14 #Put the size of the response into rdi
		mov rax, 1 #Write syscall
		syscall

		#Close client fd
		mov rdi, r12
		mov rax, 3
		syscall

		#Fix stack
		add rsp, 0x1000
		add rsp, 0x100
		add rsp, 16

		#End child process
		jmp .end

	.childPost:

		mov r14, rax
		#Parseing Get path from http header
        mov rcx, 5 #Start rcx at 4 after "POST "
        .loopPost:
            cmp BYTE PTR [rsp + rcx], 0x20
            je .spaceHandlePost
            inc rcx
            jmp .loopPost

        .spaceHandlePost:
            mov BYTE PTR [rsp + rcx], 0x00

        #Open file
        lea rdi, [rsp + 5]
        mov rsi, 0x41 #Read only
        mov rdx, 0x1FF #Not using mode
        mov rax, 2
        syscall

        mov r13, rax

        mov rcx, 0
        
		.findTheBody:
			cmp BYTE PTR [rsp + rcx], 0x0d
			jne .nextChar
			cmp BYTE PTR [rsp + rcx + 1], 0x0a
			jne .nextChar
			cmp BYTE PTR [rsp + rcx + 2], 0x0d
			jne .nextChar
			cmp BYTE PTR [rsp + rcx + 3], 0xa
			jne .nextChar
			jmp .foundBody

		.nextChar:
			inc rcx
			jmp .findTheBody

		.foundBody:
			#Write contents of body to file
			add rcx, 4
			mov rdi, r13
			lea rsi, [rsp + rcx]
			mov rdx, r14
			sub rdx, rcx
			mov rax, 1
			syscall

			#Close file
			mov rdi, r13
			mov rax, 3
			syscall

            #Writing HTTP Header
            mov rdi, r12
            lea rsi, [rip + response]
            mov rdx, response_len
            mov rax, 1
            syscall

			#Fix stack
            add rsp, 0x1000
            add rsp, 16

			#End child process
            jmp .end

.end:
	xor rdi, rdi #Make sure it is zero in rdi
	mov rax, 60
	syscall
