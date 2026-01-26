; op_7XNN.s - Add NN to VX (7XNN)
; Note: Pas de modification du carry flag VF

extern REGISTERS

global op_add_vx

section .text

; op_add_vx - Add NN to VX (7XNN)
; Entree: RDI = X (index du registre), RSI = NN (valeur)
; Note: Pas de modification du carry flag VF
op_add_vx:
    push rbp
    mov rbp, rsp

    lea rax, [rel REGISTERS]
    add byte [rax + rdi], sil

    leave
    ret
