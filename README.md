# CHIP-8 Emulator

A CHIP-8 emulator written in assembly language.

## Overview

CHIP-8 is an interpreted programming language developed in the 1970s for early microcomputers. This project implements a fully functional CHIP-8 emulator with the core logic written entirely in assembly.

## Technical Stack

### Core Emulator
- **Language**: Assembly (x86-64 / ARM)
- **CPU Emulation**: Full instruction set implementation
- **Memory Management**: 4KB RAM emulation
- **Timers**: Delay and sound timer implementation

### Graphics & Input Layer
- **Graphics Library**: SDL2 / SFML
- **Input Handling**: Keyboard mapping for CHIP-8 16-key hexadecimal keypad
- **Display**: 64x32 monochrome display emulation

The graphics and input layer serves as a minimal wrapper around the assembly core, handling only system I/O operations.

## Architecture

The emulator follows a clean separation of concerns:

```
┌─────────────────────────┐
│   Graphics & Input      │  ← C/C++ + SDL2/SFML (wrapper only)
├─────────────────────────┤
│   Core Emulator Logic   │  ← Assembly (CPU, memory, opcodes)
└─────────────────────────┘
```

All emulation logic (instruction decoding, execution, memory management, registers) is implemented in assembly. The high-level language portion is strictly limited to:
- Window creation and rendering
- Keyboard event polling
- Audio output

## Building

*(Build instructions to be added)*

## Dependencies

- libc
- SDL2 or SFML (graphics library)
- Assembler (NASM/GAS for x86-64, or appropriate assembler for chosen architecture)

## Usage

*(Usage instructions to be added)*

## License

*(License information to be added)*
