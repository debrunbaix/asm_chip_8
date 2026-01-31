#ifndef AUDIO_H
#define AUDIO_H

// Gestion du son pour l'emulateur CHIP-8
// Beep 440Hz via Raylib

// Initialise le device audio et genere le son beep
// Retourne 1 si l'audio est pret, 0 sinon
int init_audio(void);

// Joue le beep si pas deja en cours
void play_beep(void);

// Arrete le beep si en cours
void stop_beep(void);

// Libere les ressources audio
void cleanup_audio(void);

#endif
