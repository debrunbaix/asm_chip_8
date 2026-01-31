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

---

# Qu'est-ce que le CHIP-8 ?

---

## Qu'est-ce que le CHIP-8 ?

- Langage interprété créé dans les **années 70**
- Conçu pour simplifier le développement de jeux sur micro-ordinateurs
- Résolution **64×32 pixels** monochromes
- **16 touches** d'entrée (0-F)
- **35 opcodes** (instructions de 2 octets)
- Utilisé sur : COSMAC VIP, Telmac 1800, HP-48

---

## Qu'est-ce que le CHIP-8 ? | Spécifications

<div class="columns">
<div>

- **Mémoire :** 4 Ko (4096 octets)
- **Registres :** V0-VF (16 × 8 bits)
- **Registre I :** 16 bits (adressage)
- **PC :** Program Counter (16 bits)
- **Stack :** 16 niveaux
- **Timers :** Delay + Sound (60 Hz)

</div>
<div>

<div class="mem-bar">
<div style="flex:1;background:#C57979;">0x000 Fontset</div>
<div style="flex:2;background:#555;">0x050 Réservé</div>
<div style="flex:7;background:#50fa7b;">0x200 ROM / Programme</div>
</div>

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

- Emulateur écrit en **assembleur x86-64** (NASM)
- Parties graphiques/audio en **C** (interfaçage avec Raylib)
- Doit émuler fidèlement les **35 opcodes** CHIP-8
- Affichage **64×32** upscalé en **640×320** (×10)
- Timers à **60 Hz**
- Gestion du son : beep **440 Hz**
- Mapping clavier QWERTY → clavier hexadécimal CHIP-8

---

# Architecture du projet

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
<div class="flow-box">opcodes/ (21 fichiers)</div>
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

# Choix techniques

---

## Choix techniques

<div class="columns">
<div>

**Assembleur x86-64 (NASM)**
- Contrainte du projet
- Contrôle total sur la mémoire
- Appels syscalls directs (ROM)
- Flag `-f elf64 -g`

**C pour le graphique**
- Interfaçage avec Raylib simplifié
- Gestion audio/input plus haut niveau
- Linkage avec `gcc -no-pie`

</div>
<div>

**Raylib**
- Bibliothèque légère (vs SDL)
- Gestion fenêtre + audio + input
- API simple et directe

**Compilation**
- `nasm` → objets `.o` (ASM)
- `gcc` → objets `.o` (C)
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

<div class="flow">
<div class="flow-row">
<div class="flow-box">Fetch</div>
<div class="flow-arrow">→</div>
<div class="flow-box">Decode</div>
<div class="flow-arrow">→</div>
<div class="flow-box">Execute</div>
<div class="flow-arrow">→</div>
<div class="flow-diamond">10 cycles ?</div>
</div>
<div class="flow-row">
<div class="flow-label">Non ↑ boucle</div>
<div style="width:200px"></div>
<div class="flow-label">Oui ↓</div>
</div>
<div class="flow-row">
<div class="flow-box">Render Display</div>
<div class="flow-arrow">→</div>
<div class="flow-box">Update Timers</div>
<div class="flow-arrow">→</div>
<div class="flow-box">Update Input</div>
<div class="flow-arrow">→</div>
<div class="flow-label">↑ retour au Fetch</div>
</div>
</div>

<br>

**10 opcodes** exécutés par frame → **600 opcodes/s** à 60 FPS
*(fidèle au CHIP-8 original ~500 Hz)*

---

## Fonctionnement | Fetch (cpu.s)

<div class="columns">
<div>

1. Lire **2 octets** depuis `MEMORY[PC]`
2. Combiner en opcode 16 bits
3. Incrémenter `PC += 2`
4. Vérifier `PC ∈ [0x200, 0xFFE]`

</div>
<div>

<div class="flow">
<div class="flow-box">PC = 0x200</div>
<div class="flow-arrow">↓</div>
<div class="flow-row">
<div class="flow-box">high = MEMORY[PC]</div>
<div class="flow-box">low = MEMORY[PC+1]</div>
</div>
<div class="flow-arrow">↓</div>
<div class="flow-box">opcode = (high &lt;&lt; 8) | low</div>
<div class="flow-arrow">↓</div>
<div class="flow-box">PC += 2</div>
<div class="flow-arrow">↓</div>
<div class="flow-box">Retourne opcode dans RAX</div>
</div>

</div>
</div>

---

## Fonctionnement | Decode (dispatcher.s)

<div class="columns">
<div>

Extraction du **premier nibble** (4 bits hauts) pour router vers le bon handler :

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

- **V0-VE :** Registres généraux 8 bits
- **VF :** Flag (carry, collision)
- **I :** Adressage mémoire (16 bits)
- **PC :** Compteur programme
- **SP :** Pointeur de pile (0-15)

**Initialisation `init_chip8` :**
- PC → 0x200
- Copie fontset en mémoire
- Efface registres, display, keypad
- Reset timers

</div>
</div>

---

## Fonctionnement | Chargement ROM (rom_loader.s)

<div class="columns">
<div>

Chargement via **syscalls Linux** directs (pas de libc) :

1. `open()` — syscall 0x2
2. `read()` — max 3584 octets
3. `close()` — syscall 0x3

La ROM est chargée directement à l'adresse `MEMORY + 0x200`

</div>
<div>

<div class="flow">
<div class="flow-box">open(rom_path)</div>
<div class="flow-arrow">↓</div>
<div class="flow-diamond">Succès ?</div>
<div class="flow-row">
<div class="flow-label">Oui ↓</div>
<div style="width:60px"></div>
<div class="flow-label">Non → retourne 0</div>
</div>
<div class="flow-box">read(fd, MEMORY+0x200, 3584)</div>
<div class="flow-arrow">↓</div>
<div class="flow-box">close(fd)</div>
<div class="flow-arrow">↓</div>
<div class="flow-box">Retourne 1 (succès)</div>
</div>

</div>
</div>

---

## Fonctionnement | Boucle Principale (main.s)

<div class="columns">
<div>

```
./chip8_emu roms/tetris.ch8 FF0000
```

1. Parse arguments (ROM + couleur)
2. `init_chip8()` → état CPU
3. `rom_loader()` → ROM en mémoire
4. `parse_hex_color()` → couleur pixels
5. `init_display()` → fenêtre Raylib
6. **Boucle** : 10 cycles + render
7. `cleanup_display()` → fermeture

</div>
<div>

<div class="flow">
<div class="flow-box">Parse args (ROM + couleur)</div>
<div class="flow-arrow">↓</div>
<div class="flow-box">init_chip8()</div>
<div class="flow-arrow">↓</div>
<div class="flow-box">rom_loader()</div>
<div class="flow-arrow">↓</div>
<div class="flow-box">init_display()</div>
<div class="flow-arrow">↓</div>
<div class="flow-diamond">Quit ?</div>
<div class="flow-row">
<div class="flow-label">Non → 10× fetch+exec → render → ↑</div>
</div>
<div class="flow-row">
<div class="flow-label">Oui ↓</div>
</div>
<div class="flow-box">cleanup_display() → Exit</div>
</div>

</div>
</div>

---

# Quelques opcodes interessants

---

## Opcodes | DXYN — Dessiner un sprite

<div class="columns">
<div>

**Draw(VX, VY, N)**

1. Lire coordonnées VX, VY
2. Wrap : `X % 64`, `Y % 32`
3. VF = 0 (flag collision)
4. Pour chaque ligne (0..N-1) :
   - Lire sprite à `MEMORY[I + row]`
   - Pour chaque bit (8 pixels) :
     - **XOR** avec le buffer DISPLAY
     - Si pixel effacé → VF = 1

</div>
<div>

<div class="flow">
<div class="flow-box">X = VX % 64, Y = VY % 32</div>
<div class="flow-arrow">↓</div>
<div class="flow-box">VF = 0</div>
<div class="flow-arrow">↓</div>
<div class="flow-box">Pour row = 0..N-1</div>
<div class="flow-arrow">↓</div>
<div class="flow-box">sprite = MEMORY[I + row]</div>
<div class="flow-arrow">↓</div>
<div class="flow-box">Pour col = 0..7</div>
<div class="flow-arrow">↓</div>
<div class="flow-diamond">bit set ?</div>
<div class="flow-row">
<div class="flow-label">Oui → XOR pixel → collision ? → VF=1</div>
</div>
</div>

</div>
</div>

---

## Opcodes | DXYN — Buffer Display

Le buffer DISPLAY = **256 octets** (64×32 / 8)

```
Byte index = (y × 64 + x) / 8
Bit index  = 7 - (x % 8)

Pixel ON/OFF = (DISPLAY[byte] >> bit) & 1
XOR pixel    = DISPLAY[byte] ^= (1 << bit)
```

Chaque octet contient **8 pixels** horizontaux (bit 7 = gauche, bit 0 = droite)

<div class="mem-bar">
<div style="flex:1;background:#C57979;">bit 7</div>
<div style="flex:1;background:#a05555;">bit 6</div>
<div style="flex:1;background:#804444;">bit 5</div>
<div style="flex:1;background:#603333;">bit 4</div>
<div style="flex:1;background:#502222;">bit 3</div>
<div style="flex:1;background:#401818;">bit 2</div>
<div style="flex:1;background:#301010;">bit 1</div>
<div style="flex:1;background:#200808;">bit 0</div>
</div>

← gauche &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp; droite →

---

## Opcodes | 2NNN / 00EE — Call & Return

<div class="columns">
<div>

**2NNN — Call Subroutine :**
- `STACK[SP] = PC`
- `SP++`
- `PC = NNN`

**00EE — Return :**
- `SP--`
- `PC = STACK[SP]`

Stack de **16 niveaux** (16 × 16 bits)

</div>
<div>

<div class="flow-group">
<div class="flow-group-title">2NNN — Call</div>
<div class="flow">
<div class="flow-box">STACK[SP] = PC</div>
<div class="flow-arrow">↓</div>
<div class="flow-box">SP++</div>
<div class="flow-arrow">↓</div>
<div class="flow-box">PC = NNN</div>
</div>
</div>
<br>
<div class="flow-group">
<div class="flow-group-title">00EE — Return</div>
<div class="flow">
<div class="flow-box">SP--</div>
<div class="flow-arrow">↓</div>
<div class="flow-box">PC = STACK[SP]</div>
</div>
</div>

</div>
</div>

---

## Opcodes | Arithmétique 8XYx

<div class="columns">
<div>

| Opcode | Opération | VF |
|--------|-----------|-----|
| 8XY0 | VX = VY | — |
| 8XY1 | VX \|= VY | 0 |
| 8XY2 | VX &= VY | 0 |
| 8XY3 | VX ^= VY | 0 |
| 8XY4 | VX += VY | carry |
| 8XY5 | VX -= VY | !borrow |
| 8XY6 | VX >>= 1 | LSB |
| 8XY7 | VX = VY-VX | !borrow |
| 8XYE | VX <<= 1 | MSB |

</div>
<div>

**Carry (8XY4) :**
`VF = 1` si résultat > 255

**Borrow (8XY5) :**
`VF = 1` si VX >= VY (pas d'emprunt)

**Shift (8XY6) :**
`VF = bit perdu` avant le décalage

</div>
</div>

---

## Opcodes | CXNN — Nombre aléatoire

<div class="columns">
<div>

`VX = random() & NN`

Utilise un **LFSR 64 bits** (Linear Feedback Shift Register) :

```
seed ^= (seed >> 2)
seed ^= (seed >> 3)
seed ^= (seed >> 5)
seed <<= 1
seed |= new_bit
VX = (seed & 0xFF) & NN
```

</div>
<div>

<div class="flow">
<div class="flow-box">Seed 64 bits</div>
<div class="flow-arrow">↓</div>
<div class="flow-box">XOR shifts (>> 2, 3, 5)</div>
<div class="flow-arrow">↓</div>
<div class="flow-box">Nouveau bit généré</div>
<div class="flow-arrow">↓</div>
<div class="flow-box">seed = (seed &lt;&lt; 1) | bit</div>
<div class="flow-arrow">↓</div>
<div class="flow-box">& 0xFF → & NN</div>
<div class="flow-arrow">↓</div>
<div class="flow-box">VX = résultat</div>
</div>

</div>
</div>

---

## Opcodes | FX0A — Attendre une touche

<div class="columns">
<div>

- Scan `KEYPAD[0..15]`
- Si touche trouvée → `VX = index`
- Si aucune touche → `PC -= 2`

Le `PC -= 2` re-exécute la même instruction → **bloquant**

</div>
<div>

<div class="flow">
<div class="flow-box">FX0A exécuté</div>
<div class="flow-arrow">↓</div>
<div class="flow-box">Scan KEYPAD[0..15]</div>
<div class="flow-arrow">↓</div>
<div class="flow-diamond">Touche pressée ?</div>
<div class="flow-row">
<div class="flow-label">Oui → VX = key → Continue</div>
</div>
<div class="flow-row">
<div class="flow-label">Non → PC -= 2 → ↑ re-exécute</div>
</div>
</div>

</div>
</div>

---

## Opcodes | FX33 — BCD (Décimal)

Stocke les **3 chiffres décimaux** de VX en mémoire :

- `MEMORY[I]` = centaines
- `MEMORY[I+1]` = dizaines
- `MEMORY[I+2]` = unités

**Exemple :** VX = 234 → `MEMORY[I] = 2`, `MEMORY[I+1] = 3`, `MEMORY[I+2] = 4`

Utilisé pour afficher des **scores** à l'écran.

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
- 35 opcodes implémentés en ASM
- Affichage, son et input via Raylib
- Personnalisation couleur des pixels
- ~600 Hz fidèle à l'original

</div>
<div>

**Difficultés :**
- Debug assembleur x86-64
- Gestion des bits pour le display
- Interfaçage ASM ↔ C
- Respect des conventions d'appel

**Améliorations possibles :**
- Support SUPER CHIP-8 (128×64)
- Sauvegarde d'état
- Interface de sélection de ROM

</div>
</div>

---

## Merci

#### Questions ?
