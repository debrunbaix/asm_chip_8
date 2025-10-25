# Nom de l'exécutable
NAME = chip8_emu

# Compilateurs et assembleur
ASM = nasm
LD = ld
CC = gcc

# Flags
ASMFLAGS = -f elf64 -g
LDFLAGS = 
CFLAGS = -Wall -Wextra -Werror -g

# Répertoires
SRC_DIR = src
ASM_DIR = $(SRC_DIR)/asm
C_DIR = $(SRC_DIR)/c
BUILD_DIR = build
INC_DIR = include

# Fichiers sources
ASM_SRCS = $(ASM_DIR)/main.s \
           $(ASM_DIR)/chip8_state.s \
           $(ASM_DIR)/rom_loader.s \
           $(ASM_DIR)/cpu.s

C_SRCS = 

# Fichiers objets
ASM_OBJS = $(ASM_SRCS:$(ASM_DIR)/%.s=$(BUILD_DIR)/%.o)
C_OBJS = $(C_SRCS:$(C_DIR)/%.c=$(BUILD_DIR)/%.o)
OBJS = $(ASM_OBJS) $(C_OBJS)

# Règle par défaut
all: $(BUILD_DIR) $(NAME)

# Créer le répertoire build
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# Lier avec ld si que de l'ASM, sinon avec gcc
ifeq ($(C_SRCS),)
$(NAME): $(OBJS)
	$(LD) $(OBJS) -o $(NAME) $(LDFLAGS)
	@echo "✓ Compilation réussie : $(NAME)"
else
$(NAME): $(OBJS)
	$(CC) $(OBJS) -o $(NAME) $(LDFLAGS)
	@echo "✓ Compilation réussie : $(NAME)"
endif

# Compiler les fichiers assembleur
$(BUILD_DIR)/%.o: $(ASM_DIR)/%.s
	$(ASM) $(ASMFLAGS) $< -o $@

# Compiler les fichiers C
$(BUILD_DIR)/%.o: $(C_DIR)/%.c
	$(CC) $(CFLAGS) -I$(INC_DIR) -c $< -o $@

# Nettoyer les fichiers objets
clean:
	rm -rf $(BUILD_DIR)
	@echo "✓ Fichiers objets supprimés"

# Nettoyer tout
fclean: clean
	rm -f $(NAME)
	@echo "✓ Exécutable supprimé"

# Recompiler
re: fclean all

# Tester avec une ROM
test: all
	./$(NAME)

# Déboguer avec GDB
debug: all
	gdb ./$(NAME)

.PHONY: all clean fclean re test debug
