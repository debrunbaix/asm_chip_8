# CHIP-8 Emulator

A CHIP-8 emulator written primarily in x86-64 assembly (NASM), with graphics handling in C using Raylib.

## Overview

CHIP-8 is an interpreted programming language developed in the mid-1970s for 8-bit microcomputers. This emulator accurately implements the CHIP-8 specification, allowing you to run classic games and programs designed for this platform.

### Features

- Full CHIP-8 instruction set implementation (35 opcodes)
- 64x32 pixel monochrome display with configurable pixel color
- Sound support with 440Hz beep tone
- Keyboard input mapping for the 16-key hexadecimal keypad
- 60 FPS rendering with accurate timer emulation

## Requirements

### Dependencies

- **NASM** - Netwide Assembler (for assembling x86-64 code)
- **GCC** - GNU Compiler Collection (for linking and C code)
- **Raylib** - Graphics library for display and audio
- **X11** - X Window System libraries

### Installing Dependencies

On Arch Linux:
```bash
sudo pacman -S nasm gcc raylib
```

On Ubuntu/Debian:
```bash
sudo apt install nasm gcc libraylib-dev libx11-dev
```

## Building

Clone the repository and compile:

```bash
make
```

This will create the `chip8_emu` executable.

### Make Targets

| Target    | Description                              |
|-----------|------------------------------------------|
| `make`    | Build the emulator                       |
| `make clean` | Remove object files                   |
| `make fclean` | Remove object files and executable   |
| `make re` | Clean rebuild                            |
| `make test` | Build and run the emulator             |
| `make debug` | Build and launch with GDB             |

## Usage

```bash
./chip8_emu <rom_file> [color]
```

### Arguments

| Argument   | Required | Description                                      |
|------------|----------|--------------------------------------------------|
| `rom_file` | Yes      | Path to a CHIP-8 ROM file (.ch8)                |
| `color`    | No       | Custom pixel color in hexadecimal format (RRGGBB)|

### Examples

Run a ROM with default white pixels:
```bash
./chip8_emu roms/games/tetris.ch8
```

Run a ROM with custom red pixels:
```bash
./chip8_emu roms/games/space_invaders.ch8 F23838
```

Run a ROM with custom green pixels:
```bash
./chip8_emu roms/test/test_ibm.ch8 00FF00
```

## Keyboard Mapping

The CHIP-8 uses a 16-key hexadecimal keypad. This emulator maps it to a QWERTY keyboard:

```
CHIP-8 Keypad          Keyboard Mapping
+---+---+---+---+      +---+---+---+---+
| 1 | 2 | 3 | C |      | 1 | 2 | 3 | 4 |
+---+---+---+---+      +---+---+---+---+
| 4 | 5 | 6 | D |      | Q | W | E | R |
+---+---+---+---+      +---+---+---+---+
| 7 | 8 | 9 | E |      | A | S | D | F |
+---+---+---+---+      +---+---+---+---+
| A | 0 | B | F |      | Z | X | C | V |
+---+---+---+---+      +---+---+---+---+
```

## Project Structure

```
.
├── Makefile
├── include/
│   ├── display.h           # Display interface header
│   ├── input.h             # Keyboard input header
│   ├── audio.h             # Audio/beep header
│   └── timers.h            # Timers header
├── src/
│   ├── asm/
│   │   ├── main.s          # Entry point and main loop
│   │   ├── cpu.s           # Opcode fetch and debug functions
│   │   ├── chip8_state.s   # CPU state (registers, memory, stack)
│   │   ├── rom_loader.s    # ROM file loading
│   │   └── opcodes/        # Individual opcode implementations
│   │       ├── dispatcher.s
│   │       ├── op_00E0.s   # Clear screen
│   │       ├── op_00EE.s   # Return from subroutine
│   │       ├── op_1NNN.s   # Jump
│   │       ├── op_2NNN.s   # Call subroutine
│   │       ├── op_3XNN.s   # Skip if VX == NN
│   │       ├── op_4XNN.s   # Skip if VX != NN
│   │       ├── op_5XY0.s   # Skip if VX == VY
│   │       ├── op_6XNN.s   # Set VX = NN
│   │       ├── op_7XNN.s   # Add NN to VX
│   │       ├── op_8XYx.s   # Arithmetic operations
│   │       ├── op_9XY0.s   # Skip if VX != VY
│   │       ├── op_ANNN.s   # Set I = NNN
│   │       ├── op_BNNN.s   # Jump to V0 + NNN
│   │       ├── op_CXNN.s   # Random number
│   │       ├── op_DXYN.s   # Draw sprite
│   │       ├── op_EXxx.s   # Key press operations
│   │       └── op_FXxx.s   # Misc operations (timers, I, BCD, etc.)
│   └── c/
│       ├── display.c       # Raylib window, pixel rendering
│       ├── input.c         # Keyboard to CHIP-8 keypad mapping
│       ├── audio.c         # 440Hz beep generation and playback
│       └── timers.c        # Delay and sound timer management
└── roms/
    ├── games/              # Game ROMs
    │   ├── space_invaders.ch8
    │   ├── tetris.ch8
    │   └── Tron.ch8
    └── test/               # Test ROMs
        ├── test_ibm.ch8
        ├── test_opcode.ch8
        └── ...
```

## Technical Details

### CHIP-8 Specifications

| Component       | Specification                    |
|-----------------|----------------------------------|
| Memory          | 4 KB (4096 bytes)               |
| Registers       | 16 general-purpose 8-bit (V0-VF)|
| Index Register  | 16-bit (I)                       |
| Program Counter | 16-bit (PC)                      |
| Stack           | 16 levels of 16-bit addresses   |
| Display         | 64x32 pixels monochrome         |
| Timers          | Delay timer, Sound timer (60Hz) |
| Keypad          | 16 keys (0-9, A-F)              |

### Implementation Notes

- Programs are loaded at memory address 0x200
- The fontset (0-F sprites) is stored at address 0x000-0x04F
- The emulator runs 10 opcodes per frame at 60 FPS
- Timers decrement at 60Hz as per specification

## License

This project is provided for educational purposes.
