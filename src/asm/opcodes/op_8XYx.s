; op_8XYx.s - Operations arithmetiques et logiques (8XY0-8XYE)

extern REGISTERS

global op_set_vx_vy      ; 8XY0 - VX = VY
global op_or_vx_vy       ; 8XY1 - VX = VX | VY
global op_and_vx_vy      ; 8XY2 - VX = VX & VY
global op_xor_vx_vy      ; 8XY3 - VX = VX ^ VY
global op_add_vx_vy      ; 8XY4 - VX = VX + VY (avec carry)
global op_sub_vx_vy      ; 8XY5 - VX = VX - VY (avec borrow)
global op_shr_vx         ; 8XY6 - VX = VX >> 1
global op_subn_vx_vy     ; 8XY7 - VX = VY - VX (avec borrow)
global op_shl_vx         ; 8XYE - VX = VX << 1

section .text

; 8XY0 - Set VX = VY
; Entree: RDI = X, RSI = Y
op_set_vx_vy:
    push rbp
    mov rbp, rsp

    lea rax, [rel REGISTERS]
    movzx rcx, byte [rax + rsi]  ; VY
    mov byte [rax + rdi], cl     ; VX = VY

    leave
    ret

; 8XY1 - Set VX = VX | VY
; Entree: RDI = X, RSI = Y
op_or_vx_vy:
    push rbp
    mov rbp, rsp

    lea rax, [rel REGISTERS]
    movzx rcx, byte [rax + rsi]  ; VY
    or byte [rax + rdi], cl      ; VX = VX | VY

    ; Note: Certaines implementations mettent VF a 0
    mov byte [rax + 0xF], 0

    leave
    ret

; 8XY2 - Set VX = VX & VY
; Entree: RDI = X, RSI = Y
op_and_vx_vy:
    push rbp
    mov rbp, rsp

    lea rax, [rel REGISTERS]
    movzx rcx, byte [rax + rsi]  ; VY
    and byte [rax + rdi], cl     ; VX = VX & VY

    ; Note: Certaines implementations mettent VF a 0
    mov byte [rax + 0xF], 0

    leave
    ret

; 8XY3 - Set VX = VX ^ VY
; Entree: RDI = X, RSI = Y
op_xor_vx_vy:
    push rbp
    mov rbp, rsp

    lea rax, [rel REGISTERS]
    movzx rcx, byte [rax + rsi]  ; VY
    xor byte [rax + rdi], cl     ; VX = VX ^ VY

    ; Note: Certaines implementations mettent VF a 0
    mov byte [rax + 0xF], 0

    leave
    ret

; 8XY4 - Add VY to VX with carry
; Entree: RDI = X, RSI = Y
; VF = 1 si overflow, sinon 0
op_add_vx_vy:
    push rbp
    mov rbp, rsp
    push rbx

    lea rax, [rel REGISTERS]
    movzx rcx, byte [rax + rdi]  ; VX
    movzx rdx, byte [rax + rsi]  ; VY

    ; Addition
    add cl, dl

    ; Verifier overflow (carry)
    mov bl, 0
    jnc .no_carry
    mov bl, 1
.no_carry:
    ; Stocker resultat
    mov byte [rax + rdi], cl
    mov byte [rax + 0xF], bl

    pop rbx
    leave
    ret

; 8XY5 - Subtract VY from VX with borrow
; Entree: RDI = X, RSI = Y
; VF = 1 si PAS de borrow (VX >= VY), sinon 0
op_sub_vx_vy:
    push rbp
    mov rbp, rsp
    push rbx

    lea rax, [rel REGISTERS]
    movzx rcx, byte [rax + rdi]  ; VX
    movzx rdx, byte [rax + rsi]  ; VY

    ; VF = 1 si VX >= VY (pas de borrow)
    mov bl, 1
    cmp cl, dl
    jae .no_borrow
    mov bl, 0
.no_borrow:
    ; Soustraction
    sub cl, dl
    mov byte [rax + rdi], cl
    mov byte [rax + 0xF], bl

    pop rbx
    leave
    ret

; 8XY6 - Shift VX right by 1
; Entree: RDI = X, RSI = Y (certaines impl utilisent VY)
; VF = bit de poids faible avant le shift
op_shr_vx:
    push rbp
    mov rbp, rsp

    lea rax, [rel REGISTERS]
    ; Certaines impl: VX = VY d'abord (comportement original)
    ; Ici on utilise le comportement moderne: shift VX directement
    movzx rcx, byte [rax + rdi]  ; VX

    ; Sauvegarder le bit de poids faible dans VF
    mov dl, cl
    and dl, 1

    ; Shift right
    shr cl, 1
    mov byte [rax + rdi], cl
    mov byte [rax + 0xF], dl

    leave
    ret

; 8XY7 - Set VX = VY - VX with borrow
; Entree: RDI = X, RSI = Y
; VF = 1 si PAS de borrow (VY >= VX), sinon 0
op_subn_vx_vy:
    push rbp
    mov rbp, rsp
    push rbx

    lea rax, [rel REGISTERS]
    movzx rcx, byte [rax + rdi]  ; VX
    movzx rdx, byte [rax + rsi]  ; VY

    ; VF = 1 si VY >= VX (pas de borrow)
    mov bl, 1
    cmp dl, cl
    jae .no_borrow
    mov bl, 0
.no_borrow:
    ; Soustraction: VX = VY - VX
    sub dl, cl
    mov byte [rax + rdi], dl
    mov byte [rax + 0xF], bl

    pop rbx
    leave
    ret

; 8XYE - Shift VX left by 1
; Entree: RDI = X, RSI = Y
; VF = bit de poids fort avant le shift
op_shl_vx:
    push rbp
    mov rbp, rsp

    lea rax, [rel REGISTERS]
    movzx rcx, byte [rax + rdi]  ; VX

    ; Sauvegarder le bit de poids fort dans VF
    mov dl, cl
    shr dl, 7
    and dl, 1

    ; Shift left
    shl cl, 1
    mov byte [rax + rdi], cl
    mov byte [rax + 0xF], dl

    leave
    ret
