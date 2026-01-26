---
marp: true
theme: custom
paginate: true
---

# Émulateur CHIP-8

Développement d'un émulateur en assembleur x86-64
### - Debrunbaix

---

## Sommaire

- Qu'est-ce que le CHIP-8 ?
- Architecture du projet
- Choix techniques
- Fonctionnement de l'émulateur
- Démonstration
- Conclusion

---

# Qu'est-ce que le CHIP-8 ?

---

## Qu'est-ce que le CHIP-8 ?

- Langage interprété créé dans les années 1970
- Conçu pour les micro-ordinateurs 8 bits
- Permet de créer des jeux simples (Pong, Tetris, Space Invaders...)
- Spécifications simples : idéal pour apprendre l'émulation

<!-- TODO: Ajouter une image d'un ordinateur COSMAC VIP des années 70 -->

---

## Spécifications du CHIP-8

<div class="columns">
<div>

**Mémoire et registres**
- 4 Ko de mémoire RAM
- 16 registres 8 bits (V0 à VF)
- 1 registre d'index 16 bits (I)
- 1 compteur de programme (PC)

</div>
<div>

**Autres composants**
- Pile de 16 niveaux
- Écran 64x32 pixels
- 2 timers (délai et son)
- Clavier hexadécimal 16 touches

</div>
</div>

---

## Organisation de la mémoire

<!-- TODO: Ajouter un schéma de l'organisation mémoire CHIP-8 -->
<!-- Schéma montrant:
     0x000 - 0x1FF : Interpréteur/Fontset
     0x200 - 0xFFF : Programme et données
-->

| Adresse | Contenu |
|---------|---------|
| 0x000 - 0x04F | Fontset (sprites 0-F) |
| 0x050 - 0x1FF | Réservé |
| 0x200 - 0xFFF | Programme ROM |

---

# Architecture du projet

---

## Structure des fichiers

```
├── src/
│   ├── asm/           # Code assembleur (logique)
│   │   ├── main.s
│   │   ├── cpu.s
│   │   ├── chip8_state.s
│   │   └── opcodes/   # Implémentation des 35 opcodes
│   └── c/             # Code C (affichage)
│       └── display.c
└── include/
    └── display.h
```

---

## Séparation des responsabilités

<!-- TODO: Ajouter un schéma d'architecture montrant la séparation ASM/C -->

<div class="columns">
<div>

**Assembleur x86-64**
- Boucle principale
- Gestion de la mémoire
- Registres CPU
- Exécution des opcodes
- Toute la logique de l'émulateur

</div>
<div>

**C avec Raylib**
- Initialisation fenêtre
- Rendu graphique
- Gestion du son
- Entrées clavier
- Encapsulation uniquement

</div>
</div>

---

# Choix techniques

---

## Pourquoi x86-64 ?

- Architecture la plus répandue sur PC
- Documentation abondante
- Outils de débogage performants (GDB)
- Registres 64 bits puissants pour manipuler les données
- Compatibilité avec l'écosystème Linux

---

## Pourquoi Raylib ?

<div class="columns">
<div>

**Avantages**
- Librairie légère et simple
- API intuitive en C
- Gestion audio intégrée
- Cross-platform
- Facile à interfacer avec l'assembleur

</div>
<div>

**Utilisation**
- Fenêtre 640x320 pixels (x10)
- 60 FPS
- Son 440 Hz pour le beep
- Mapping clavier QWERTY

</div>
</div>

---

## Mapping clavier

```
Clavier CHIP-8          Clavier QWERTY
+---+---+---+---+       +---+---+---+---+
| 1 | 2 | 3 | C |       | 1 | 2 | 3 | 4 |
+---+---+---+---+       +---+---+---+---+
| 4 | 5 | 6 | D |       | Q | W | E | R |
+---+---+---+---+       +---+---+---+---+
| 7 | 8 | 9 | E |       | A | S | D | F |
+---+---+---+---+       +---+---+---+---+
| A | 0 | B | F |       | Z | X | C | V |
+---+---+---+---+       +---+---+---+---+
```

---

# Fonctionnement de l'émulateur

---

## Cycle de l'émulateur

<!-- TODO: Ajouter un diagramme du cycle Fetch-Decode-Execute -->

1. **Fetch** : Lire l'opcode à l'adresse PC (2 octets)
2. **Decode** : Identifier l'instruction parmi les 35 possibles
3. **Execute** : Exécuter l'instruction
4. **Render** : Afficher l'écran si nécessaire
5. **Repeat** : Recommencer

---

## État du CPU en assembleur

```nasm
section .bss
    MEMORY:      resb 0x1000    ; 4 Ko de RAM
    REGISTERS:   resb 0x10      ; V0-VF
    STACK:       resw 0x10      ; Pile 16 niveaux
    PC:          resw 0x1       ; Compteur programme
    REG_I:       resw 0x1       ; Registre Index
    DELAY_TIMER: resb 0x1       ; Timer délai
    SOUND_TIMER: resb 0x1       ; Timer son
    DISPLAY:     resb 256       ; Buffer écran
```

---

## Le dispatcher d'opcodes

<!-- TODO: Ajouter un schéma montrant le flux de décodage des opcodes -->

- Chaque opcode fait 2 octets (big-endian)
- Le premier nibble (4 bits) détermine la catégorie
- Exemple : `0x6XNN` → Charger NN dans VX

```
Opcode 0xA2F0:
├── A = Catégorie (Set I)
├── 2F0 = Adresse
└── Action: I = 0x2F0
```

---

## Les 35 opcodes implémentés

<div class="columns">
<div>

| Opcode | Description |
|--------|-------------|
| 00E0 | Effacer l'écran |
| 00EE | Retour de sous-routine |
| 1NNN | Saut à l'adresse NNN |
| 2NNN | Appel sous-routine |
| 3XNN | Skip si VX == NN |
| 4XNN | Skip si VX != NN |
| 5XY0 | Skip si VX == VY |

</div>
<div>

| Opcode | Description |
|--------|-------------|
| 6XNN | VX = NN |
| 7XNN | VX += NN |
| 8XY_ | Opérations arithmétiques |
| DXYN | Afficher sprite |
| EX__ | Entrées clavier |
| FX__ | Timers, mémoire, BCD |

</div>
</div>

---

## L'opcode DXYN : Affichage

<!-- TODO: Ajouter un schéma/animation montrant le XOR sur les pixels -->

- Dessine un sprite de 8 pixels de large et N pixels de haut
- Position : coordonnées (VX, VY)
- Utilise l'opération XOR pour afficher
- VF = 1 si collision (pixel effacé)

**C'est l'opcode le plus complexe !**

---

## Gestion des timers

- Deux timers décrémentes à 60 Hz
- **Delay Timer** : Utilisé pour la synchronisation des jeux
- **Sound Timer** : Émet un son tant que > 0

```c
void update_timers(void) {
    if (DELAY_TIMER > 0) DELAY_TIMER--;
    if (SOUND_TIMER > 0) {
        PlaySound(beep_sound);
        SOUND_TIMER--;
    }
}
```

---

## Interface ASM ↔ C

<!-- TODO: Ajouter un schéma montrant l'interface entre ASM et C -->

L'assembleur appelle les fonctions C via la convention d'appel System V AMD64 :

- `init_display()` : Initialiser Raylib
- `render_display()` : Dessiner le buffer
- `check_quit()` : Vérifier si on ferme
- `update_keypad()` : Lire les touches

---

## Boucle principale (main.s)

```nasm
.main_loop:
    call check_quit          ; Quitter ?
    test eax, eax
    jnz .quit

    mov r12, 10              ; 10 opcodes/frame
.cpu_cycle:
    call fetch_opcode        ; Fetch
    call execute_opcode      ; Decode + Execute
    dec r12
    jnz .cpu_cycle

    call render_display      ; Render à 60 FPS
    jmp .main_loop
```

---

## Fonctionnalités bonus

- **Couleur personnalisable** : `./chip8_emu rom.ch8 FF0000`
- Parse la couleur hexadécimale en assembleur
- Permet de jouer avec différentes ambiances visuelles

<!-- TODO: Ajouter des captures d'écran avec différentes couleurs -->

---

# Démonstration

<!-- TODO: Préparer une démo live avec :
     - Test IBM logo (test_ibm.ch8)
     - Un jeu (Space Invaders, Tetris ou Pong)
     - Montrer le changement de couleur
-->

---

## Tests effectués

| ROM | Description | Statut |
|-----|-------------|--------|
| test_ibm.ch8 | Affiche le logo IBM | ✓ |
| test_opcode.ch8 | Test tous les opcodes | ✓ |
| keypad.ch8 | Test du clavier | ✓ |
| delay_timer.ch8 | Test des timers | ✓ |
| Space Invaders | Jeu classique | ✓ |
| Tetris | Jeu classique | ✓ |

---

# Conclusion

---

## Ce que j'ai appris

- Programmation bas niveau en assembleur x86-64
- Fonctionnement interne d'un CPU (fetch-decode-execute)
- Interfaçage assembleur/C
- Gestion de la mémoire et des registres
- Émulation de systèmes historiques

---

## Difficultés rencontrées

- Débogage de l'assembleur (GDB indispensable)
- Gestion du big-endian pour les opcodes
- Implémentation correcte de l'opcode DXYN
- Synchronisation des timers à 60 Hz
- Convention d'appel entre ASM et C

---

## Améliorations possibles

- Ajout d'un mode debug pas-à-pas
- Changement de ROM sans redémarrer
- Sauvegarde/restauration d'état
- Support SUPER CHIP-8 (écran 128x64)
- Interface graphique pour sélectionner les ROMs

---

# Questions ?

### Merci de votre attention !

**Code source :** github.com/debrunbaix

---
