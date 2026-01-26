; op_CXNN.s - Set VX = random AND NN (CXNN)

extern REGISTERS

global op_random

section .data
    ; Simple LFSR seed (sera mis a jour a chaque appel)
    random_seed: dq 0x12345678

section .text

; op_random - Set VX = random AND NN (CXNN)
; Entree: RDI = X (index du registre), RSI = NN (masque)
op_random:
    push rbp
    mov rbp, rsp
    push rbx

    ; Generer un nombre pseudo-aleatoire (LFSR)
    mov rax, [rel random_seed]

    ; LFSR: bit = seed ^ (seed >> 2) ^ (seed >> 3) ^ (seed >> 5)
    mov rbx, rax
    shr rbx, 2
    xor rax, rbx
    mov rbx, rax
    shr rbx, 3
    xor rax, rbx
    mov rbx, rax
    shr rbx, 5
    xor rax, rbx

    ; Shift et ajouter le nouveau bit
    shl qword [rel random_seed], 1
    and rax, 1
    or [rel random_seed], rax

    ; Utiliser les 8 bits bas du seed comme nombre aleatoire
    mov rax, [rel random_seed]
    and rax, 0xFF

    ; Appliquer le masque NN
    and rax, rsi

    ; Stocker dans VX
    lea rbx, [rel REGISTERS]
    mov byte [rbx + rdi], al

    pop rbx
    leave
    ret
