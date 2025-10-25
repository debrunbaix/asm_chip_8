# struture du projet :

```bash
chip8-emulator/
│
├── README.md
├── Makefile
├── LICENSE
│
├── include/
│   ├── chip8.h              # Déclarations des fonctions ASM exposées
│   ├── display.h            # Interface d'affichage (C)
│   └── audio.h              # Interface audio (C)
│
├── src/
│   ├── asm/
│   │   ├── main.asm         # Point d'entrée principal (ASM)
│   │   ├── cpu.asm          # Émulation CPU et cycle fetch-decode-execute
│   │   ├── opcodes.asm      # Implémentation des instructions CHIP-8
│   │   ├── memory.asm       # Gestion de la RAM (4KB)
│   │   ├── registers.asm    # Gestion des registres V0-VF, I, PC, SP
│   │   ├── timers.asm       # Timers delay et sound
│   │   ├── stack.asm        # Gestion de la pile
│   │   └── utils.asm        # Fonctions utilitaires
│   │
│   └── c/
│       ├── display.c        # Implémentation SDL2/SFML pour l'affichage
│       └── audio.c          # Implémentation audio (beep du timer)
│
├── roms/
│   ├── test/
│   │   └── test_opcode.ch8  # ROMs de test
│   └── games/
│       ├── pong.ch8
│       ├── tetris.ch8
│       └── space_invaders.ch8
│
├── data/
│   └── font.bin             # Police sprite CHIP-8 (0-F)
│
├── build/
│   └── .gitkeep
│
└── docs/
    ├── CHIP8_SPEC.md        # Spécifications CHIP-8
    ├── OPCODES.md           # Liste des opcodes
    └── ARCHITECTURE.md      # Documentation de l'architecture
```
