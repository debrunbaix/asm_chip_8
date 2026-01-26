; op_2NNN.s - Call subroutine at NNN (2NNN)
; Empile PC et saute a NNN

extern CH8_SP
extern STACK
extern PC

global op_call

section .text

; op_call - Call subroutine at NNN (2NNN)
; Entree: RDI = NNN (adresse)
; Empile PC actuel puis saute a NNN
op_call:
    push rbp
    mov rbp, rsp

    ; Sauvegarder l'adresse de saut
    mov rsi, rdi

    ; Empiler PC actuel sur la stack
    movzx rcx, byte [rel CH8_SP]
    lea rax, [rel STACK]
    mov dx, word [rel PC]
    mov word [rax + rcx*2], dx

    ; Incrementer SP
    lea rax, [rel CH8_SP]
    inc byte [rax]

    ; Sauter a NNN
    mov word [rel PC], si

    leave
    ret
