extern	init_chip8
extern	rom_loader
extern  fetch_opcode
extern  print_opcode

global	_start

section .data
	test_rom: db "roms/test/test_opcode.ch8", 0
  msg_start: db "=== Lecture des opcodes ===", 10, 0
  msg_end: db "=== Fin ===", 10, 0

section	.text

_start:
	push	rbp
	mov		rbp, rsp

	call	init_chip8

	lea		rdi, [rel test_rom]
	call	rom_loader

	test rax, rax
  jz .error

  ; Afficher message de début
  mov rax, 1
  mov rdi, 1
  lea rsi, [rel msg_start]
  mov rdx, 28
  syscall
  
  ; Lire et afficher 20 opcodes
  mov r12, 20

	;mov rax, 60
	;xor rdi, rdi
	;syscall

  .loop:
    ; Fetch l'opcode
    call fetch_opcode
    test rax, rax
    jz .done
    
    ; Afficher l'opcode
    mov rdi, rax
    call print_opcode
    
    ; Continuer
    dec r12
    jnz .loop
    
  .done:
    ; Afficher message de fin
    mov rax, 1
    mov rdi, 1
    lea rsi, [rel msg_end]
    mov rdx, 12
    syscall
    
    ; Exit succès
    mov rax, 60
    xor rdi, rdi
    syscall

.error:
	mov rax, 60
	mov rdi, 1
	syscall
