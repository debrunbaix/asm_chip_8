; op_ANNN.s - Set I = NNN (ANNN)

extern REG_I

global op_set_i

section .text

; op_set_i - Set I = NNN (ANNN)
; Entree: RDI = NNN (adresse)
op_set_i:
    push rbp
    mov rbp, rsp

    mov word [rel REG_I], di

    leave
    ret
