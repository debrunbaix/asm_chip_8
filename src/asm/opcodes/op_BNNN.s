extern REGISTERS
extern PC

global op_jump_v0

section .text

; op_jump_v0 - Jump to V0 + NNN (BNNN)
; Entree: RDI = NNN (adresse)
op_jump_v0:
    push rbp
    mov rbp, rsp

    ; Obtenir V0
    lea rax, [rel REGISTERS]
    movzx rax, byte [rax]  ; V0

    ; Ajouter NNN
    add rax, rdi

    ; Mettre PC a V0 + NNN
    mov word [rel PC], ax

    leave
    ret
