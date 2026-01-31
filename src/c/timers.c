#include <stdint.h>
#include "timers.h"
#include "audio.h"

extern uint8_t DELAY_TIMER;
extern uint8_t SOUND_TIMER;

void update_timers(void)
{
    if (DELAY_TIMER > 0)
    {
        DELAY_TIMER--;
    }

    if (SOUND_TIMER > 0)
    {
        play_beep();
        SOUND_TIMER--;
    }
    else
    {
        stop_beep();
    }
}
