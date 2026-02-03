extern PC
extern MEMORY

global fetch_opcode
global print_opcode

section .data
  opcode_msg: db "Opcode: 0x", 0
  hex_chars: db "0123456789ABCDEF"
  newline: db 10

section .bss
  hex_buffer: resb 5

section .text

fetch_opcode:
  push rbp
  mov  rbp, rsp

  ; PC dans RAX
  movzx rax, word [rel PC]

  ; vérifie que 0x200 < PC < 0xFFE (là ou la ROM est chargée).
  cmp rax, 0x200
  jl .error
  cmp rax, 0xFFE
  jge .error

  lea rbx, [rel MEMORY]
  movzx rcx, byte [rbx + rax]
  movzx rdx, byte [rbx + rax + 1]

  ; Combiner: opcode = (high << 8) | low
  shl rcx, 8
  or rcx, rdx
  add word [rel PC], 2

  mov rax, rcx
  leave
  ret

  .error:
    xor rax, rax
    leave
    ret

; Focntion de DEBUG pour vérifier le fetch (inutilisé en production)
print_opcode:
  push rbp
  mov rbp, rsp
  push rbx
  push r12

  mov r12, rdi

  ; Afficher "Opcode: 0x"
  mov rax, 1
  mov rdi, 1
  lea rsi, [rel opcode_msg]
  mov rdx, 11
  syscall

  ; Convertir l'opcode en 4 caractères hexa
  lea rbx, [rel hex_chars]

  ; Nibble 1 (bits 15-12)
  mov rax, r12
  shr rax, 12
  and rax, 0xF
  mov al, byte [rbx + rax]
  mov byte [rel hex_buffer], al

  ; Nibble 2 (bits 11-8)
  mov rax, r12
  shr rax, 8
  and rax, 0xF
  mov al, byte [rbx + rax]
  mov byte [rel hex_buffer + 1], al

  ; Nibble 3 (bits 7-4)
  mov rax, r12
  shr rax, 4
  and rax, 0xF
  mov al, byte [rbx + rax]
  mov byte [rel hex_buffer + 2], al

  ; Nibble 4 (bits 3-0)
  mov rax, r12
  and rax, 0xF
  mov al, byte [rbx + rax]
  mov byte [rel hex_buffer + 3], al

  ; Newline
  mov byte [rel hex_buffer + 4], 10

  ; Afficher
  mov rax, 1
  mov rdi, 1
  lea rsi, [rel hex_buffer]
  mov rdx, 5
  syscall

  pop r12
  pop rbx
  leave
  ret
