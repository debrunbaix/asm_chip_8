extern init_chip8
extern rom_loader
extern fetch_opcode
extern execute_opcode

; Fonctions C pour l'affichage (Raylib)
extern init_display
extern render_display
extern check_quit
extern cleanup_display
extern delay_ms
extern set_pixel_color

global main

section .data
    msg_start: db "=== CHIP-8 Emulator ===", 10, 0
    msg_load_ok: db "[+] ROM chargee avec succes", 10, 0
    msg_load_err: db "[-] Erreur chargement ROM", 10, 0
    msg_end: db "[+] Fermeture de l'emulateur", 10, 0
    msg_usage: db "Usage: ./chip8_emu <rom_file> [color (ex: F23838)]", 10, 0
    msg_usage_len equ 52
    msg_color: db "[+] Couleur personnalisee: ", 0

section .text

main:
    push rbp
    mov rbp, rsp
    push r12
    push r13
    push r14
    push r15
    sub rsp, 16

    ; Sauvegarder argc et argv
    mov r14, rdi                ; r14 = argc
    mov r15, rsi                ; r15 = argv

    ; Verifier qu'on a un argument (argc >= 2)
    cmp r14, 2
    jl .usage_error

    ; Afficher message de demarrage
    mov rax, 1
    mov rdi, 1
    lea rsi, [rel msg_start]
    mov rdx, 25
    syscall

    ; Initialiser l'etat CHIP-8
    call init_chip8

    ; Charger la ROM (argv[1] = chemin de la ROM)
    mov rdi, [r15 + 8]
    call rom_loader
    test rax, rax
    jz .load_error

    ; Message ROM chargee
    mov rax, 1
    mov rdi, 1
    lea rsi, [rel msg_load_ok]
    mov rdx, 28
    syscall

    ; Verifier si une couleur a ete specifiee (argc >= 3)
    cmp r14, 3
    jl .skip_color

    ; Parser la couleur hexadecimale (argv[2])
    mov rdi, [r15 + 16] ;Deuxième argument
    call parse_hex_color
    mov rdi, rax
    call set_pixel_color

.skip_color:
    ; Initialiser l'affichage Raylib
    call init_display

.main_loop:
    ; Verifier si l'utilisateur veut quitter
    call check_quit
    test eax, eax
    jnz .quit

    ; Executer plusieurs cycles par frame
    mov r12, 10

.cpu_cycle:
    ; Fetch opcode
    call fetch_opcode
    test rax, rax
    jz .render_frame

    ; Executer opcode
    mov rdi, rax
    call execute_opcode

    dec r12
    jnz .cpu_cycle

.render_frame:
    ; Afficher le buffer
    call render_display

    jmp .main_loop

.quit:
    ; Nettoyer l'affichage
    call cleanup_display

    ; Message de fin
    mov rax, 1
    mov rdi, 1
    lea rsi, [rel msg_end]
    mov rdx, 31
    syscall

    ; Exit succes
    xor eax, eax
    jmp .exit

.usage_error:
    ; Afficher message d'usage
    mov rax, 1
    mov rdi, 2                  ; stderr
    lea rsi, [rel msg_usage]
    mov rdx, msg_usage_len
    syscall
    mov eax, 1
    jmp .exit

.load_error:
    ; Message d'erreur
    mov rax, 1
    mov rdi, 1
    lea rsi, [rel msg_load_err]
    mov rdx, 26
    syscall
    mov eax, 1

.exit:
    add rsp, 16
    pop r15
    pop r14
    pop r13
    pop r12
    leave
    ret

; parse_hex_color - Parse une chaine hex
parse_hex_color:
    push rbx
    xor rax, rax

.parse_loop:
    movzx rbx, byte [rdi]
    test bl, bl
    jz .done

    shl rax, 4

    ; Convertir le caractere hex
    cmp bl, '0'
    jl .done
    cmp bl, '9'
    jle .digit

    cmp bl, 'A'
    jl .check_lower
    cmp bl, 'F'
    jle .upper_letter

.check_lower:
    cmp bl, 'a'
    jl .done
    cmp bl, 'f'
    jg .done
    ; Lettre minuscule a-f
    sub bl, 'a'
    add bl, 10
    jmp .add_digit

.upper_letter:
    ; Lettre majuscule A-F
    sub bl, 'A'
    add bl, 10
    jmp .add_digit

.digit:
    ; Chiffre 0-9
    sub bl, '0'

.add_digit:
    or al, bl
    inc rdi
    jmp .parse_loop

.done:
    pop rbx
    ret
