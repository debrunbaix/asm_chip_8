---
marp: true
theme: custom
paginate: true
html: true
---

# Emulateur CHIP-8

Developpement d'un emulateur en assembleur x86-64

### Debrunbaix

---

## Sommaire

1. Qu'est-ce que le CHIP-8 ?
2. Contraintes du projet
3. Architecture du projet
4. Choix techniques
5. Fonctionnement de l'emulateur
6. Quelques opcodes interessants
7. Changement de couleur des pixels
8. Demonstration
9. Conclusion
10. Questions

---

# Qu'est-ce que le CHIP-8 ?

---

## Qu'est-ce que le CHIP-8 ?

<div class="columns">
<div>

- Langage interprété créé dans les **années 70**
- Conçu faire du developpement de jeu sur micro ordinateur.
- Résolution **64×32 pixels** monochromes
- **16 touches** d'entrée (0-F)
- **35 opcodes** (instructions de 2 octets)
- Utilisé sur : COSMAC VIP, Telmac 1800, HP-48

</div>
<div>

<img src="assets/RCA_Cosmac_VIP.jpg" style="width: 70%;">

</div>
</div>

---

## Qu'est-ce que le CHIP-8 ? | Spécifications

<div class="columns">
<div>

- **Mémoire :** 4 Ko (4096 octets)
- **Registres :** V0-VF (16 × 8 bits)
- **Registre I :** 16 bits (adressage)
- **PC :** Program Counter (16 bits)
- **Stack :** 16 niveaux

</div>
<div>

| Zone | Adresse | Taille |
|------|---------|--------|
| Fontset | 0x000-0x04F | 80 o |
| Réservé | 0x050-0x1FF | 432 o |
| ROM | 0x200-0xFFF | 3584 o |

</div>
</div>

---

# Contraintes du projet

---

## Contraintes du projet

- Emulateur/logique écrit en **assembleur**
- Parties graphiques/audio en **C**

---

# Architecture du projet

---

## Architecture du projet | Arborescence

<div class="columns">
<div>

```
asm_chip_8/
├── Makefile
├── include/
│   ├── display.h
│   ├── audio.h
│   ├── input.h
│   └── timers.h
├── src/
│   ├── asm/
│   │   ├── main.s
│   │   ├── chip8_state.s
│   │   ├── cpu.s
│   │   ├── rom_loader.s
│   │   └── opcodes/ (21 fichiers)
│   └── c/
│       ├── display.c
│       ├── audio.c
│       ├── input.c
│       └── timers.c
└── roms/
```

</div>
<div>

| Fichier | Rôle |
|---------|------|
| `main.s` | Point d'entrée, boucle principale |
| `chip8_state.s` | État CPU, mémoire, fontset |
| `cpu.s` | Fetch des opcodes |
| `rom_loader.s` | Chargement ROM (syscalls) |
| `dispatcher.s` | Décodage et dispatch |
| `display.c` | Rendu Raylib |
| `audio.c` | Beep 440 Hz (sine) |
| `input.c` | Mapping clavier |
| `timers.c` | Timers 60 Hz |

</div>
</div>

---

## Architecture du projet | Vue d'ensemble

<div class="columns">
<div>

<div class="flow-group">
<div class="flow-group-title">Assembleur x86-64</div>
<div class="flow">
<div class="flow-box">main.s</div>
<div class="flow-arrow">↓ ↓ ↓</div>
<div class="flow-row">
<div class="flow-box">cpu.s</div>
<div class="flow-box">chip8_state.s</div>
<div class="flow-box">rom_loader.s</div>
</div>
<div class="flow-arrow">↓</div>
<div class="flow-box">dispatcher.s</div>
<div class="flow-arrow">↓</div>
<div class="flow-box">opcodes/</div>
</div>
</div>

</div>
<div>

<div class="flow-group">
<div class="flow-group-title">C + Raylib</div>
<div class="flow">
<div class="flow-box">display.c</div>
<div class="flow-arrow">↓ ↓ ↓</div>
<div class="flow-row">
<div class="flow-box">input.c</div>
<div class="flow-box">timers.c</div>
<div class="flow-box">audio.c</div>
</div>
</div>
</div>

<br>

**main.s** appelle les fonctions C via les conventions d'appel x86-64 (System V ABI)

</div>
</div>

---

# Choix techniques

---

## Choix techniques

<div class="columns">
<div>

**Assembleur x86-64 (NASM)**
- 20% ARM client (TechInsights)
- Plus compétent sur ce langage

**C pour le graphique**
- Interfaçage avec Raylib simplifié
- Gestion audio/input plus haut niveau

</div>
<div>

**Raylib**
- Bibliothèque légère (vs SDL)
- Gestion fenêtre + audio + input
- API simple et directe

**Compilation**
- `nasm` -> objets `.o` (ASM)
- `gcc` -> objets `.o` (C)
- `gcc` link tout avec Raylib

```
-lraylib -lGL -lm
-lpthread -ldl -lrt -lX11
```

</div>
</div>

---

# Fonctionnement de l'emulateur

---

## Fonctionnement | Cycle Fetch-Decode-Execute

![image](assets/fetch_decode_exec.png)

---

## Fonctionnement | Fetch (cpu.s)

1. Lire **2 octets** depuis `MEMORY[PC]`
2. Combiner en opcode.
3. Incrémenter `PC += 2`
4. Vérifier `PC in [0x200, 0xFFE]`

---

## Fonctionnement | Decode (dispatcher.s)

<div class="columns">
<div>

Extraction du **premier nibble** 

| Nibble | Opcodes |
|--------|---------|
| 0 | 00E0, 00EE |
| 1 | 1NNN (Jump) |
| 2 | 2NNN (Call) |
| 6 | 6XNN (Set) |
| 8 | 8XY0-8XYE |
| D | DXYN (Draw) |
| F | FXxx (Timers...) |

</div>
<div>

<div class="flow">
<div class="flow-box">opcode = 0xDXYN</div>
<div class="flow-arrow">↓</div>
<div class="flow-box">nibble = opcode >> 12</div>
<div class="flow-arrow">↓</div>
<div class="flow-diamond">nibble ?</div>
<div class="flow-arrow">↓</div>
<div class="flow-row">
<div class="flow-box">0x0 → CLS/RET</div>
<div class="flow-box">0x1 → Jump</div>
</div>
<div class="flow-row">
<div class="flow-box">0x8 → ALU</div>
<div class="flow-box">0xD → Draw</div>
</div>
<div class="flow-row">
<div class="flow-box">0xF → Misc</div>
<div class="flow-box">... → Autres</div>
</div>
</div>

</div>
</div>

---

## Fonctionnement | État CPU (chip8_state.s)

<div class="columns">
<div>

| Composant | Taille |
|-----------|--------|
| `MEMORY` | 4096 octets |
| `REGISTERS` | 16 octets (V0-VF) |
| `STACK` | 32 octets (16 × 16 bits) |
| `CH8_SP` | 1 octet |
| `PC` | 2 octets |
| `REG_I` | 2 octets |
| `KEYPAD` | 16 octets |
| `DELAY_TIMER` | 1 octet |
| `SOUND_TIMER` | 1 octet |
| `DISPLAY` | 256 octets |

</div>
<div>

**Initialisation `init_chip8` :**
- PC → 0x200
- Copie fontset en mémoire
- Efface registres, display, keypad
- Reset timers

```as
•••
xor rax, rax
mov rcx, 0x1000
lea rdi, [rel MEMORY]
rep stosb
•••
```

</div>
</div>

---

## Fonctionnement | Chargement ROM (rom_loader.s)

Chargement via **syscalls Linux**:

1. open() 
2. read() 
3. close() 

La ROM est chargée directement à l'adresse `MEMORY + 0x200`

---

## Fonctionnement | Boucle Principale (main.s)

<div class="columns">
<div>

```
./chip8_emu roms/tetris.ch8 FF0000
```

1. Parse arguments (ROM + couleur)
2. init\_chip8() → état CPU
3. rom\_loader() → ROM en mémoire
4. parse\_hex\_color() → couleur pixels
5. init\_display() → fenêtre Raylib
6. **Boucle** : 10 cycles + render
7. cleanup\_display() → fermeture

</div>
<div>

<img src="assets/loop.png" style="width: 70%;">

</div>
</div>

---

# Quelques opcodes interessants

---

## Opcodes | CXNN — Nombre aléatoire

<div class="columns">
<div>

- Algo LFSR
- X = Registre cible
- NN = masque

</div>
<div>

<img src="assets/random.png" style="width: 70%;">

</div>
</div>

---

## Opcodes | 8XYx - Opérateurs arithmetiques.

<div class="columns">
<div>

- Premier bit (8) type d'opcode
- dernier bit (x) type d'opération arithmetique

</div>
<div>

```as
.check_8XYx:
    mov rax, r12
    and rax, 0xF

    •••

    cmp rax, 0x0
    je .do_8xy0
    cmp rax, 0x1
    je .do_8xy1
    •••
    •••
    cmp rax, 0xE
    je .do_8xyE
```

</div>
</div>

---

# Changement de couleur des pixels

---

## Changement de couleur des pixels

<div class="columns">
<div>

**Argument optionnel** au lancement :

```
./chip8_emu rom.ch8 F23838
```

**Parsing en ASM** (`parse_hex_color`) :
- Lit chaque caractère (0-9, A-F, a-f)
- Convertit en nibble (4 bits)
- Construit `result = (result << 4) | nibble`
- Résultat : `0xRRGGBB`

</div>
<div>

**En C** (`set_pixel_color`) :
- Extrait R, G, B du format hex
- Alpha = 255 (opaque)
- Stocke dans variable statique

```c
void set_pixel_color(uint32_t hex) {
    pixel_color.r = (hex >> 16) & 0xFF;
    pixel_color.g = (hex >> 8) & 0xFF;
    pixel_color.b = hex & 0xFF;
    pixel_color.a = 255;
}
```

Couleur par défaut : **blanc** (0xFFFFFF)

</div>
</div>

---

## Changement de couleur | Rendu

<div class="columns">
<div>

Pour chaque pixel allumé :

```c
DrawRectangle(
    x * 10, y * 10,
    10, 10,
    pixel_color
);
```

- Scale ×10 : **640×320** pixels réels
- Fond : **noir**
- Pixels ON : couleur configurée

</div>
<div>

<div class="flow">
<div class="flow-diamond">Couleur fournie ?</div>
<div class="flow-row">
<div class="flow-label">Oui ↓</div>
<div style="width:40px"></div>
<div class="flow-label">Non ↓</div>
</div>
<div class="flow-row">
<div class="flow-box">parse_hex_color()</div>
<div style="width:10px"></div>
<div class="flow-box">Blanc par défaut</div>
</div>
<div class="flow-arrow">↓</div>
<div class="flow-box">set_pixel_color(0xRRGGBB)</div>
<div class="flow-arrow">↓</div>
<div class="flow-box">DrawRectangle avec la couleur</div>
</div>

</div>
</div>

---

# Demonstration

---

## Demonstration

```
./chip8_emu roms/games/tetris.ch8
./chip8_emu roms/games/pong.ch8 00FF00
./chip8_emu roms/games/space_invaders.ch8 F23838
```

---

# Conclusion

---

## Conclusion

<div class="columns">
<div>

**Réalisations :**
- Emulateur CHIP-8 fonctionnel
- Opcodes implémentés en ASM
- Affichage, son et input via Raylib
- Personnalisation couleur des pixels

</div>
<div>

**Difficultés :**
- Debug assembleur x86-64
- Interfaçage ASM <-> C
- Respect des conventions d'appel

**Améliorations possibles :**
- Implementation ARM sur raspberry avec vrai clavier.
- Interface de sélection de ROM

</div>
</div>

---

## Merci

#### Questions ?
