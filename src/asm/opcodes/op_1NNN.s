extern PC

global op_jump

section .text

; op_jump - Saute a l'adresse NNN (1NNN)
; Entree: RDI = adresse NNN
op_jump:
    push rbp
    mov rbp, rsp

    ; Mettre PC a NNN
    mov word [rel PC], di

    leave
    ret
