extern REGISTERS
extern KEYPAD
extern PC

global op_skip_key_pressed    ; EX9E - Skip if key VX pressed
global op_skip_key_not_pressed ; EXA1 - Skip if key VX not pressed

section .text

; EX9E - Skip if key VX is pressed
; Entree: RDI = X (index du registre)
op_skip_key_pressed:
    push rbp
    mov rbp, rsp

    ; Obtenir la valeur de VX (numero de la touche 0-F)
    lea rax, [rel REGISTERS]
    movzx rax, byte [rax + rdi]
    and rax, 0xF              ; S'assurer que c'est 0-F

    ; Verifier si cette touche est pressee
    lea rcx, [rel KEYPAD]
    movzx rcx, byte [rcx + rax]

    test cl, cl
    jz .no_skip

    ; Skip: PC += 2
    add word [rel PC], 2

.no_skip:
    leave
    ret

; EXA1 - Skip if key VX is NOT pressed
; Entree: RDI = X (index du registre)
op_skip_key_not_pressed:
    push rbp
    mov rbp, rsp

    ; Obtenir la valeur de VX (numero de la touche 0-F)
    lea rax, [rel REGISTERS]
    movzx rax, byte [rax + rdi]
    and rax, 0xF              ; S'assurer que c'est 0-F

    ; Verifier si cette touche n'est PAS pressee
    lea rcx, [rel KEYPAD]
    movzx rcx, byte [rcx + rax]

    test cl, cl
    jnz .no_skip

    ; Skip: PC += 2
    add word [rel PC], 2

.no_skip:
    leave
    ret
