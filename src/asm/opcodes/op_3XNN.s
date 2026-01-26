; op_3XNN.s - Skip if VX == NN (3XNN)
; Skip l'instruction suivante si VX == NN

extern REGISTERS
extern PC

global op_skip_eq

section .text

; op_skip_eq - Skip if VX == NN (3XNN)
; Entree: RDI = X (index du registre), RSI = NN (valeur)
op_skip_eq:
    push rbp
    mov rbp, rsp

    ; Obtenir VX
    lea rax, [rel REGISTERS]
    movzx rax, byte [rax + rdi]

    ; Comparer avec NN
    cmp al, sil
    jne .no_skip

    ; Skip: PC += 2
    add word [rel PC], 2

.no_skip:
    leave
    ret
