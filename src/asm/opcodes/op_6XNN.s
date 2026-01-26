; op_6XNN.s - Set VX = NN (6XNN)

extern REGISTERS

global op_set_vx

section .text

; op_set_vx - Set VX = NN (6XNN)
; Entree: RDI = X (index du registre), RSI = NN (valeur)
op_set_vx:
    push rbp
    mov rbp, rsp

    lea rax, [rel REGISTERS]
    mov byte [rax + rdi], sil

    leave
    ret
