extern	PC
extern	MEMORY

global	rom_loader

section	.text

rom_loader:
	push	rbp
	mov		rbp, rsp
	push	r12
	push	rbx

	mov		r12, rdi

	; ouverture du fichier via le syscall Open
	mov		rax, 0x2
	mov		rdi, r12
	xor		rsi, rsi
	xor		rdx, rdx
	syscall

	cmp		rax, 0x0
	jl		.error

	; Sauvegarde du FD dans RBX
	mov		rbx, rax

	; Placement des opcodes dans la mémoire via le syscall Read
	mov		rax, 0x0
	mov		rdi, rbx
	lea		rsi, [rel MEMORY + 0x200]
	mov		rdx, 0xE00
	syscall

	; Fermer le fichier via le syscall Close
	mov		rax, 3
	mov		rdi, rbx
	syscall

	mov		rax, 0x1
	jmp		.end

	.error:
		xor		rax, rax

	.end:
		pop		rbx
		pop		r12
		leave
		ret
