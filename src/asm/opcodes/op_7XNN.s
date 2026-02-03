extern REGISTERS

global op_add_vx

section .text

; op_add_vx - Add NN to VX (7XNN)
; Entree: RDI = X (index du registre), RSI = NN (valeur)
op_add_vx:
    push rbp
    mov rbp, rsp

    lea rax, [rel REGISTERS]
    add byte [rax + rdi], sil

    leave
    ret
