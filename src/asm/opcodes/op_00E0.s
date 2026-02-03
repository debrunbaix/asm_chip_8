extern DISPLAY

global op_clear_screen

section .text

; op_clear_screen - Efface l'ecran (00E0)
; Met tous les pixels du buffer DISPLAY a 0
op_clear_screen:
    push rbp
    mov rbp, rsp

    ; Effacer 256 octets du display
    xor rax, rax
    mov rcx, 256
    lea rdi, [rel DISPLAY]
    rep stosb

    leave
    ret
