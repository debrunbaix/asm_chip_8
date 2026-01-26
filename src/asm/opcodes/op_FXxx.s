; op_FXxx.s - Opcodes FX07, FX0A, FX15, FX18, FX1E, FX29, FX33, FX55, FX65

extern REGISTERS
extern MEMORY
extern REG_I
extern DELAY_TIMER
extern SOUND_TIMER
extern KEYPAD
extern PC

global op_get_delay        ; FX07 - VX = delay timer
global op_wait_key         ; FX0A - Wait for key press
global op_set_delay        ; FX15 - delay timer = VX
global op_set_sound        ; FX18 - sound timer = VX
global op_add_i_vx         ; FX1E - I = I + VX
global op_set_i_font       ; FX29 - I = font sprite for VX
global op_bcd              ; FX33 - Store BCD of VX at I
global op_store_regs       ; FX55 - Store V0-VX at I
global op_load_regs        ; FX65 - Load V0-VX from I

section .text

; FX07 - Set VX = delay timer
; Entree: RDI = X (index du registre)
op_get_delay:
    push rbp
    mov rbp, rsp

    ; Obtenir la valeur du delay timer
    movzx rax, byte [rel DELAY_TIMER]

    ; Stocker dans VX
    lea rcx, [rel REGISTERS]
    mov byte [rcx + rdi], al

    leave
    ret

; FX0A - Wait for key press, store in VX
; Entree: RDI = X (index du registre)
; Si aucune touche n'est pressee, decremente PC pour re-executer
op_wait_key:
    push rbp
    mov rbp, rsp
    push rbx
    push r12

    mov r12, rdi              ; Sauvegarder X

    ; Parcourir toutes les touches (0-F)
    xor rbx, rbx
.check_keys:
    cmp rbx, 16
    jge .no_key_pressed

    lea rax, [rel KEYPAD]
    movzx rax, byte [rax + rbx]
    test al, al
    jnz .key_found

    inc rbx
    jmp .check_keys

.key_found:
    ; Stocker le numero de la touche dans VX
    lea rax, [rel REGISTERS]
    mov byte [rax + r12], bl
    jmp .done

.no_key_pressed:
    ; Aucune touche pressee, revenir en arriere pour re-executer
    sub word [rel PC], 2

.done:
    pop r12
    pop rbx
    leave
    ret

; FX15 - Set delay timer = VX
; Entree: RDI = X (index du registre)
op_set_delay:
    push rbp
    mov rbp, rsp

    ; Obtenir VX
    lea rax, [rel REGISTERS]
    movzx rax, byte [rax + rdi]

    ; Mettre dans delay timer
    mov byte [rel DELAY_TIMER], al

    leave
    ret

; FX18 - Set sound timer = VX
; Entree: RDI = X (index du registre)
op_set_sound:
    push rbp
    mov rbp, rsp

    ; Obtenir VX
    lea rax, [rel REGISTERS]
    movzx rax, byte [rax + rdi]

    ; Mettre dans sound timer
    mov byte [rel SOUND_TIMER], al

    leave
    ret

; FX1E - Add VX to I
; Entree: RDI = X (index du registre)
op_add_i_vx:
    push rbp
    mov rbp, rsp

    ; Obtenir VX
    lea rax, [rel REGISTERS]
    movzx rax, byte [rax + rdi]

    ; Ajouter a I
    add word [rel REG_I], ax

    leave
    ret

; FX29 - Set I to font sprite address for digit VX
; Entree: RDI = X (index du registre)
; Chaque sprite de font fait 5 bytes, stockes a partir de 0x000
op_set_i_font:
    push rbp
    mov rbp, rsp

    ; Obtenir VX (digit 0-F)
    lea rax, [rel REGISTERS]
    movzx rax, byte [rax + rdi]
    and rax, 0xF              ; S'assurer que c'est 0-F

    ; Calculer l'adresse: digit * 5
    mov rcx, 5
    mul rcx                   ; RAX = digit * 5

    ; Stocker dans I
    mov word [rel REG_I], ax

    leave
    ret

; FX33 - Store BCD representation of VX at I, I+1, I+2
; Entree: RDI = X (index du registre)
; I = centaines, I+1 = dizaines, I+2 = unites
op_bcd:
    push rbp
    mov rbp, rsp
    push rbx

    ; Obtenir VX
    lea rax, [rel REGISTERS]
    movzx rax, byte [rax + rdi]

    ; Obtenir l'adresse I
    movzx rbx, word [rel REG_I]
    lea rcx, [rel MEMORY]
    add rcx, rbx              ; RCX = &MEMORY[I]

    ; Calculer centaines
    xor rdx, rdx
    mov rbx, 100
    div bl                    ; AL = centaines, AH = reste
    mov byte [rcx], al        ; MEMORY[I] = centaines

    ; Calculer dizaines
    shr rax, 8                ; RAX = reste (AH -> AL)
    xor rdx, rdx
    mov r8b, 10
    div r8b                   ; AL = dizaines, AH = unites
    mov byte [rcx + 1], al    ; MEMORY[I+1] = dizaines
    shr rax, 8                ; Unites dans AL
    mov byte [rcx + 2], al    ; MEMORY[I+2] = unites

    pop rbx
    leave
    ret

; FX55 - Store V0 to VX in memory starting at I
; Entree: RDI = X (dernier registre a stocker)
; Note: I n'est PAS modifie (comportement moderne)
op_store_regs:
    push rbp
    mov rbp, rsp
    push rbx
    push r12

    mov r12, rdi              ; X = dernier registre

    ; Obtenir l'adresse I
    movzx rbx, word [rel REG_I]

    ; Boucle de 0 a X
    xor rcx, rcx
.store_loop:
    cmp rcx, r12
    jg .store_done

    ; Lire V[rcx]
    lea rax, [rel REGISTERS]
    movzx rax, byte [rax + rcx]

    ; Stocker dans MEMORY[I + rcx]
    lea rdx, [rel MEMORY]
    add rdx, rbx              ; rdx = MEMORY + I
    mov byte [rdx + rcx], al

    inc rcx
    jmp .store_loop

.store_done:
    pop r12
    pop rbx
    leave
    ret

; FX65 - Load V0 to VX from memory starting at I
; Entree: RDI = X (dernier registre a charger)
; Note: I n'est PAS modifie (comportement moderne)
op_load_regs:
    push rbp
    mov rbp, rsp
    push rbx
    push r12

    mov r12, rdi              ; X = dernier registre

    ; Obtenir l'adresse I
    movzx rbx, word [rel REG_I]

    ; Boucle de 0 a X
    xor rcx, rcx
.load_loop:
    cmp rcx, r12
    jg .load_done

    ; Lire MEMORY[I + rcx]
    lea rax, [rel MEMORY]
    add rax, rbx              ; rax = MEMORY + I
    movzx rax, byte [rax + rcx]

    ; Stocker dans V[rcx]
    lea rdx, [rel REGISTERS]
    mov byte [rdx + rcx], al

    inc rcx
    jmp .load_loop

.load_done:
    pop r12
    pop rbx
    leave
    ret
