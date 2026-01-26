; dispatcher.s - Decode et execute les opcodes CHIP-8

; Opcodes existants
extern op_clear_screen      ; 00E0
extern op_return            ; 00EE
extern op_jump              ; 1NNN
extern op_call              ; 2NNN
extern op_skip_eq           ; 3XNN
extern op_skip_neq          ; 4XNN
extern op_skip_eq_reg       ; 5XY0
extern op_set_vx            ; 6XNN
extern op_add_vx            ; 7XNN

; Opcodes 8XYx
extern op_set_vx_vy         ; 8XY0
extern op_or_vx_vy          ; 8XY1
extern op_and_vx_vy         ; 8XY2
extern op_xor_vx_vy         ; 8XY3
extern op_add_vx_vy         ; 8XY4
extern op_sub_vx_vy         ; 8XY5
extern op_shr_vx            ; 8XY6
extern op_subn_vx_vy        ; 8XY7
extern op_shl_vx            ; 8XYE

extern op_skip_neq_reg      ; 9XY0
extern op_set_i             ; ANNN
extern op_jump_v0           ; BNNN
extern op_random            ; CXNN
extern op_draw              ; DXYN

; Opcodes EXxx
extern op_skip_key_pressed      ; EX9E
extern op_skip_key_not_pressed  ; EXA1

; Opcodes FXxx
extern op_get_delay         ; FX07
extern op_wait_key          ; FX0A
extern op_set_delay         ; FX15
extern op_set_sound         ; FX18
extern op_add_i_vx          ; FX1E
extern op_set_i_font        ; FX29
extern op_bcd               ; FX33
extern op_store_regs        ; FX55
extern op_load_regs         ; FX65

global execute_opcode

section .text

; execute_opcode - Decode et execute un opcode
; Entree: RDI = opcode (16 bits)
; Sortie: RAX = 1 si succes, 0 si opcode inconnu
execute_opcode:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13

    mov r12, rdi              ; Sauvegarder l'opcode

    ; Extraire le premier nibble (bits 15-12)
    mov rax, r12
    shr rax, 12
    and rax, 0xF

    ; Dispatcher selon le premier nibble
    cmp rax, 0x0
    je .check_00XX
    cmp rax, 0x1
    je .do_jump
    cmp rax, 0x2
    je .do_call
    cmp rax, 0x3
    je .do_skip_eq
    cmp rax, 0x4
    je .do_skip_neq
    cmp rax, 0x5
    je .do_skip_eq_reg
    cmp rax, 0x6
    je .do_set_vx
    cmp rax, 0x7
    je .do_add_vx
    cmp rax, 0x8
    je .check_8XYx
    cmp rax, 0x9
    je .do_skip_neq_reg
    cmp rax, 0xA
    je .do_set_i
    cmp rax, 0xB
    je .do_jump_v0
    cmp rax, 0xC
    je .do_random
    cmp rax, 0xD
    je .do_draw
    cmp rax, 0xE
    je .check_EXxx
    cmp rax, 0xF
    je .check_FXxx

    ; Opcode inconnu
    xor rax, rax
    jmp .end

.check_00XX:
    ; Verifier si c'est 00E0 (clear screen) ou 00EE (return)
    cmp r12w, 0x00E0
    je .do_clear
    cmp r12w, 0x00EE
    je .do_return
    ; Autres opcodes 0XXX non implementes
    xor rax, rax
    jmp .end

.do_clear:
    call op_clear_screen
    mov rax, 1
    jmp .end

.do_return:
    call op_return
    mov rax, 1
    jmp .end

.do_jump:
    ; 1NNN - Jump to NNN
    mov rdi, r12
    and rdi, 0x0FFF           ; Extraire NNN
    call op_jump
    mov rax, 1
    jmp .end

.do_call:
    ; 2NNN - Call subroutine at NNN
    mov rdi, r12
    and rdi, 0x0FFF           ; Extraire NNN
    call op_call
    mov rax, 1
    jmp .end

.do_skip_eq:
    ; 3XNN - Skip if VX == NN
    mov rdi, r12
    shr rdi, 8
    and rdi, 0xF              ; X
    mov rsi, r12
    and rsi, 0xFF             ; NN
    call op_skip_eq
    mov rax, 1
    jmp .end

.do_skip_neq:
    ; 4XNN - Skip if VX != NN
    mov rdi, r12
    shr rdi, 8
    and rdi, 0xF              ; X
    mov rsi, r12
    and rsi, 0xFF             ; NN
    call op_skip_neq
    mov rax, 1
    jmp .end

.do_skip_eq_reg:
    ; 5XY0 - Skip if VX == VY
    mov rdi, r12
    shr rdi, 8
    and rdi, 0xF              ; X
    mov rsi, r12
    shr rsi, 4
    and rsi, 0xF              ; Y
    call op_skip_eq_reg
    mov rax, 1
    jmp .end

.do_set_vx:
    ; 6XNN - Set VX = NN
    mov rdi, r12
    shr rdi, 8
    and rdi, 0xF              ; X
    mov rsi, r12
    and rsi, 0xFF             ; NN
    call op_set_vx
    mov rax, 1
    jmp .end

.do_add_vx:
    ; 7XNN - Add NN to VX
    mov rdi, r12
    shr rdi, 8
    and rdi, 0xF              ; X
    mov rsi, r12
    and rsi, 0xFF             ; NN
    call op_add_vx
    mov rax, 1
    jmp .end

.check_8XYx:
    ; Extraire le dernier nibble pour determiner l'operation
    mov rax, r12
    and rax, 0xF

    ; Extraire X et Y
    mov rdi, r12
    shr rdi, 8
    and rdi, 0xF              ; X
    mov rsi, r12
    shr rsi, 4
    and rsi, 0xF              ; Y

    cmp rax, 0x0
    je .do_8xy0
    cmp rax, 0x1
    je .do_8xy1
    cmp rax, 0x2
    je .do_8xy2
    cmp rax, 0x3
    je .do_8xy3
    cmp rax, 0x4
    je .do_8xy4
    cmp rax, 0x5
    je .do_8xy5
    cmp rax, 0x6
    je .do_8xy6
    cmp rax, 0x7
    je .do_8xy7
    cmp rax, 0xE
    je .do_8xyE

    ; Opcode 8XYx inconnu
    xor rax, rax
    jmp .end

.do_8xy0:
    call op_set_vx_vy
    mov rax, 1
    jmp .end

.do_8xy1:
    call op_or_vx_vy
    mov rax, 1
    jmp .end

.do_8xy2:
    call op_and_vx_vy
    mov rax, 1
    jmp .end

.do_8xy3:
    call op_xor_vx_vy
    mov rax, 1
    jmp .end

.do_8xy4:
    call op_add_vx_vy
    mov rax, 1
    jmp .end

.do_8xy5:
    call op_sub_vx_vy
    mov rax, 1
    jmp .end

.do_8xy6:
    call op_shr_vx
    mov rax, 1
    jmp .end

.do_8xy7:
    call op_subn_vx_vy
    mov rax, 1
    jmp .end

.do_8xyE:
    call op_shl_vx
    mov rax, 1
    jmp .end

.do_skip_neq_reg:
    ; 9XY0 - Skip if VX != VY
    mov rdi, r12
    shr rdi, 8
    and rdi, 0xF              ; X
    mov rsi, r12
    shr rsi, 4
    and rsi, 0xF              ; Y
    call op_skip_neq_reg
    mov rax, 1
    jmp .end

.do_set_i:
    ; ANNN - Set I = NNN
    mov rdi, r12
    and rdi, 0x0FFF           ; NNN
    call op_set_i
    mov rax, 1
    jmp .end

.do_jump_v0:
    ; BNNN - Jump to V0 + NNN
    mov rdi, r12
    and rdi, 0x0FFF           ; NNN
    call op_jump_v0
    mov rax, 1
    jmp .end

.do_random:
    ; CXNN - VX = random AND NN
    mov rdi, r12
    shr rdi, 8
    and rdi, 0xF              ; X
    mov rsi, r12
    and rsi, 0xFF             ; NN
    call op_random
    mov rax, 1
    jmp .end

.do_draw:
    ; DXYN - Draw sprite
    mov rdi, r12
    shr rdi, 8
    and rdi, 0xF              ; X register
    mov rsi, r12
    shr rsi, 4
    and rsi, 0xF              ; Y register
    mov rdx, r12
    and rdx, 0xF              ; N (height)
    call op_draw
    mov rax, 1
    jmp .end

.check_EXxx:
    ; Extraire les deux derniers nibbles
    mov rax, r12
    and rax, 0xFF

    ; Extraire X
    mov rdi, r12
    shr rdi, 8
    and rdi, 0xF              ; X

    cmp rax, 0x9E
    je .do_skip_key_pressed
    cmp rax, 0xA1
    je .do_skip_key_not_pressed

    ; Opcode EXxx inconnu
    xor rax, rax
    jmp .end

.do_skip_key_pressed:
    call op_skip_key_pressed
    mov rax, 1
    jmp .end

.do_skip_key_not_pressed:
    call op_skip_key_not_pressed
    mov rax, 1
    jmp .end

.check_FXxx:
    ; Extraire les deux derniers nibbles
    mov rax, r12
    and rax, 0xFF

    ; Extraire X
    mov rdi, r12
    shr rdi, 8
    and rdi, 0xF              ; X

    cmp rax, 0x07
    je .do_get_delay
    cmp rax, 0x0A
    je .do_wait_key
    cmp rax, 0x15
    je .do_set_delay
    cmp rax, 0x18
    je .do_set_sound
    cmp rax, 0x1E
    je .do_add_i_vx
    cmp rax, 0x29
    je .do_set_i_font
    cmp rax, 0x33
    je .do_bcd
    cmp rax, 0x55
    je .do_store_regs
    cmp rax, 0x65
    je .do_load_regs

    ; Opcode FXxx inconnu
    xor rax, rax
    jmp .end

.do_get_delay:
    call op_get_delay
    mov rax, 1
    jmp .end

.do_wait_key:
    call op_wait_key
    mov rax, 1
    jmp .end

.do_set_delay:
    call op_set_delay
    mov rax, 1
    jmp .end

.do_set_sound:
    call op_set_sound
    mov rax, 1
    jmp .end

.do_add_i_vx:
    call op_add_i_vx
    mov rax, 1
    jmp .end

.do_set_i_font:
    call op_set_i_font
    mov rax, 1
    jmp .end

.do_bcd:
    call op_bcd
    mov rax, 1
    jmp .end

.do_store_regs:
    call op_store_regs
    mov rax, 1
    jmp .end

.do_load_regs:
    call op_load_regs
    mov rax, 1
    jmp .end

.end:
    pop r13
    pop r12
    pop rbx
    leave
    ret
