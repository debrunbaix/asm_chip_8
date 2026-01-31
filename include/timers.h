#ifndef TIMERS_H
#define TIMERS_H

// Gestion des timers CHIP-8
// DELAY_TIMER et SOUND_TIMER decrementent a 60Hz

// Met a jour les timers (a appeler une fois par frame a 60Hz)
void update_timers(void);

#endif
