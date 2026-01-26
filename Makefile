# Nom de l'exécutable
NAME = chip8_emu

# Compilateurs et assembleur
ASM = nasm
CC = gcc

# Flags
ASMFLAGS = -f elf64 -g
CFLAGS = -Wall -Wextra -g -I$(INC_DIR)
LDFLAGS = -lraylib -lGL -lm -lpthread -ldl -lrt -lX11

# Répertoires
SRC_DIR = src
ASM_DIR = $(SRC_DIR)/asm
OPCODES_DIR = $(ASM_DIR)/opcodes
C_DIR = $(SRC_DIR)/c
BUILD_DIR = build
BUILD_OPCODES_DIR = $(BUILD_DIR)/opcodes
INC_DIR = include

# Fichiers sources assembleur
ASM_SRCS = $(ASM_DIR)/main.s \
           $(ASM_DIR)/chip8_state.s \
           $(ASM_DIR)/rom_loader.s \
           $(ASM_DIR)/cpu.s

# Fichiers sources opcodes
OPCODES_SRCS = $(OPCODES_DIR)/dispatcher.s \
               $(OPCODES_DIR)/op_00E0.s \
               $(OPCODES_DIR)/op_00EE.s \
               $(OPCODES_DIR)/op_1NNN.s \
               $(OPCODES_DIR)/op_2NNN.s \
               $(OPCODES_DIR)/op_3XNN.s \
               $(OPCODES_DIR)/op_4XNN.s \
               $(OPCODES_DIR)/op_5XY0.s \
               $(OPCODES_DIR)/op_6XNN.s \
               $(OPCODES_DIR)/op_7XNN.s \
               $(OPCODES_DIR)/op_8XYx.s \
               $(OPCODES_DIR)/op_9XY0.s \
               $(OPCODES_DIR)/op_ANNN.s \
               $(OPCODES_DIR)/op_BNNN.s \
               $(OPCODES_DIR)/op_CXNN.s \
               $(OPCODES_DIR)/op_DXYN.s \
               $(OPCODES_DIR)/op_EXxx.s \
               $(OPCODES_DIR)/op_FXxx.s

# Fichiers sources C
C_SRCS = $(C_DIR)/display.c

# Fichiers objets
ASM_OBJS = $(ASM_SRCS:$(ASM_DIR)/%.s=$(BUILD_DIR)/%.o)
OPCODES_OBJS = $(OPCODES_SRCS:$(OPCODES_DIR)/%.s=$(BUILD_OPCODES_DIR)/%.o)
C_OBJS = $(C_SRCS:$(C_DIR)/%.c=$(BUILD_DIR)/%.o)
OBJS = $(ASM_OBJS) $(OPCODES_OBJS) $(C_OBJS)

# Règle par défaut
all: $(BUILD_DIR) $(BUILD_OPCODES_DIR) $(NAME)

# Créer les répertoires build
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(BUILD_OPCODES_DIR):
	mkdir -p $(BUILD_OPCODES_DIR)

# Lier avec gcc (necessaire pour Raylib et libc)
$(NAME): $(OBJS)
	$(CC) $(OBJS) -o $(NAME) $(LDFLAGS) -no-pie
	@echo "[+] Compilation réussie : $(NAME)"

# Compiler les fichiers assembleur
$(BUILD_DIR)/%.o: $(ASM_DIR)/%.s
	$(ASM) $(ASMFLAGS) $< -o $@

# Compiler les fichiers opcodes
$(BUILD_OPCODES_DIR)/%.o: $(OPCODES_DIR)/%.s
	$(ASM) $(ASMFLAGS) $< -o $@

# Compiler les fichiers C
$(BUILD_DIR)/%.o: $(C_DIR)/%.c
	$(CC) $(CFLAGS) -c $< -o $@

# Nettoyer les fichiers objets
clean:
	rm -rf $(BUILD_DIR)
	@echo "[+] Fichiers objets supprimés"

# Nettoyer tout
fclean: clean
	rm -f $(NAME)
	@echo "[+] Exécutable supprimé"

# Recompiler
re: fclean all

# Tester avec une ROM
test: all
	./$(NAME)

# Déboguer avec GDB
debug: all
	gdb ./$(NAME)

.PHONY: all clean fclean re test debug
