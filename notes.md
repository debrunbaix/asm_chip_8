# struture du projet :

```bash
chip8-emulator/
│
├── src/
│   ├── asm/                    # Code assembleur
│   │   ├── core.asm           # Point d'entrée principal
│   │   ├── cpu.asm            # Fetch-decode-execute cycle
│   │   ├── opcodes.asm        # Implémentation des 35 opcodes
│   │   ├── memory.asm         # Gestion mémoire (4Ko)
│   │   └── timers.asm         # Timers delay/sound
│   │
│   └── wrapper/                # Interface graphique (C/C++)
│       ├── main.cpp           # Point d'entrée wrapper
│       ├── display.cpp        # Affichage 64x32 (SDL2/SFML)
│       ├── input.cpp          # Clavier hexadécimal
│       └── bridge.cpp         # Interface avec l'ASM
│
├── roms/                       # ROMs de test
│   ├── test_opcode.ch8
│   ├── pong.ch8
│   └── ...
│
├── tests/
│   └── unit_tests.asm         # Tests unitaires des opcodes
│
├── docs/
│   ├── rapport.md
│   └── architecture.pdf
│
├── Makefile                    # Build system
└── README.md
```
