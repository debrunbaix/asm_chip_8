; op_00EE.s - Return from subroutine (00EE)
; Depile l'adresse de retour et la place dans PC

extern CH8_SP
extern STACK
extern PC

global op_return

section .text

; op_return - Return from subroutine (00EE)
; Decremente SP et met PC = STACK[SP]
op_return:
    push rbp
    mov rbp, rsp

    ; Decrementer SP
    lea rax, [rel CH8_SP]
    movzx rcx, byte [rax]
    dec cl
    mov byte [rax], cl

    ; Recuperer l'adresse de retour depuis la stack
    lea rax, [rel STACK]
    movzx rcx, byte [rel CH8_SP]
    movzx rdx, word [rax + rcx*2]

    ; Mettre PC a cette adresse
    mov word [rel PC], dx

    leave
    ret
