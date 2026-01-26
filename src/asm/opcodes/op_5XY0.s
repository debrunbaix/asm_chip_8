; op_5XY0.s - Skip if VX == VY (5XY0)
; Skip l'instruction suivante si VX == VY

extern REGISTERS
extern PC

global op_skip_eq_reg

section .text

; op_skip_eq_reg - Skip if VX == VY (5XY0)
; Entree: RDI = X (index du registre VX), RSI = Y (index du registre VY)
op_skip_eq_reg:
    push rbp
    mov rbp, rsp

    ; Obtenir VX et VY
    lea rax, [rel REGISTERS]
    movzx rcx, byte [rax + rdi]  ; VX
    movzx rdx, byte [rax + rsi]  ; VY

    ; Comparer VX et VY
    cmp cl, dl
    jne .no_skip

    ; Skip: PC += 2
    add word [rel PC], 2

.no_skip:
    leave
    ret
