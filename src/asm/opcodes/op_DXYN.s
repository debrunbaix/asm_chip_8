extern MEMORY
extern REGISTERS
extern REG_I
extern DISPLAY

global op_draw

section .text

; op_draw - Draw sprite at (VX, VY) with height N (DXYN)
; Entree: RDI = X register index, RSI = Y register index, RDX = N (height)
; Le sprite est lu depuis MEMORY[I]
; VF est mis a 1 si un pixel est efface, sinon 0
op_draw:
    push rbp
    mov rbp, rsp
    sub rsp, 64               ; Espace local
    push rbx
    push r12
    push r13
    push r14
    push r15

    ; Sauvegarder les parametres
    mov [rbp-8], rdx          ; N (hauteur)

    ; Obtenir les coordonnees X et Y depuis les registres
    lea rax, [rel REGISTERS]
    movzx r13, byte [rax + rdi]   ; X coord = VX
    movzx r14, byte [rax + rsi]   ; Y coord = VY

    ; Wrap les coordonnees initiales
    and r13, 63               ; X % 64
    and r14, 31               ; Y % 32

    ; VF = 0 (pas de collision initialement)
    lea rax, [rel REGISTERS]
    mov byte [rax + 0xF], 0

    ; Obtenir l'adresse du sprite dans MEMORY
    movzx r15, word [rel REG_I]
    lea rbx, [rel MEMORY]
    add rbx, r15              ; RBX = adresse du sprite

    ; Boucle sur chaque ligne du sprite
    xor r12, r12              ; row = 0
.draw_row_loop:
    cmp r12, [rbp-8]
    jge .draw_end

    ; Lire l'octet du sprite pour cette ligne
    movzx r8, byte [rbx + r12]    ; sprite_byte

    ; Si sprite_byte est 0, passer a la ligne suivante
    test r8, r8
    jz .next_row

    ; Calculer Y actuel (avec wrap)
    mov r9, r14
    add r9, r12
    and r9, 31                ; current_y = (VY + row) % 32

    ; Boucle sur chaque bit du sprite (8 pixels)
    xor r10, r10              ; col = 0
.draw_col_loop:
    cmp r10, 8
    jge .next_row

    ; Verifier si ce bit est set dans le sprite
    mov rax, 7
    sub rax, r10              ; bit_pos = 7 - col
    mov rcx, rax
    mov rax, r8
    shr rax, cl
    and rax, 1

    test rax, rax
    jz .next_col              ; Si le bit est 0, passer au suivant

    ; Calculer X actuel (avec wrap)
    mov r11, r13
    add r11, r10
    and r11, 63               ; current_x = (VX + col) % 64

    ; Calculer l'index dans le buffer DISPLAY
    ; linear_pos = current_y * 64 + current_x
    ; byte_index = linear_pos / 8
    ; bit_index = 7 - (current_x % 8)
    mov rax, r9
    shl rax, 6                ; y * 64
    add rax, r11              ; y * 64 + x
    mov rcx, rax
    shr rcx, 3                ; byte_index = linear_pos / 8
    mov [rbp-16], rcx         ; sauvegarder byte_index

    mov rax, r11
    and rax, 7                ; x % 8
    mov rdx, 7
    sub rdx, rax              ; bit_index = 7 - (x % 8)

    ; Creer le masque du bit
    mov rax, 1
    mov rcx, rdx
    shl rax, cl               ; mask = 1 << bit_index
    mov [rbp-24], rax         ; sauvegarder mask

    ; Lire le pixel actuel
    mov rcx, [rbp-16]         ; byte_index
    lea rdi, [rel DISPLAY]
    movzx rax, byte [rdi + rcx]

    ; Verifier collision (si le pixel etait deja allume)
    mov rsi, [rbp-24]         ; mask
    test rax, rsi
    jz .no_collision

    ; Collision detectee - set VF = 1
    lea rax, [rel REGISTERS]
    mov byte [rax + 0xF], 1

.no_collision:
    ; XOR le pixel
    mov rcx, [rbp-16]         ; byte_index
    mov rax, [rbp-24]         ; mask
    lea rdi, [rel DISPLAY]
    xor byte [rdi + rcx], al

.next_col:
    inc r10
    jmp .draw_col_loop

.next_row:
    inc r12
    jmp .draw_row_loop

.draw_end:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    add rsp, 64
    leave
    ret
