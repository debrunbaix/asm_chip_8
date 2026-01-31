#ifndef DISPLAY_H
#define DISPLAY_H

#include <stdint.h>

// Fonctions d'interface graphique pour l'emulateur CHIP-8
// Implementation avec Raylib

// Definit la couleur des pixels (format 0xRRGGBB)
void set_pixel_color(uint32_t hex_color);

// Initialise la fenetre d'affichage et l'audio
// Retourne 1 en cas de succes, 0 en cas d'erreur
int init_display(void);

// Affiche le contenu du buffer DISPLAY sur l'ecran
void render_display(void);

// Verifie si l'utilisateur veut quitter
// Retourne 1 si quit demande, 0 sinon
int check_quit(void);

// Ferme la fenetre et libere les ressources
void cleanup_display(void);

// Attend pendant ms millisecondes
void delay_ms(int ms);

#endif
