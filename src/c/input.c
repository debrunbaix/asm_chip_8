#include "raylib.h"
#include <stdint.h>
#include "input.h"

extern uint8_t KEYPAD[16];

// Mapping clavier QWERTY vers CHIP-8 keypad
// Layout CHIP-8:     Layout Clavier:
// 1 2 3 C            1 2 3 4
// 4 5 6 D            Q W E R
// 7 8 9 E            A S D F
// A 0 B F            Z X C V
static const int key_map[16] = {
    KEY_X,    // 0
    KEY_ONE,  // 1
    KEY_TWO,  // 2
    KEY_THREE,// 3
    KEY_Q,    // 4
    KEY_W,    // 5
    KEY_E,    // 6
    KEY_A,    // 7
    KEY_S,    // 8
    KEY_D,    // 9
    KEY_Z,    // A
    KEY_C,    // B
    KEY_FOUR, // C
    KEY_R,    // D
    KEY_F,    // E
    KEY_V     // F
};

void update_keypad(void)
{
    for (int i = 0; i < 16; i++)
    {
        KEYPAD[i] = IsKeyDown(key_map[i]) ? 1 : 0;
    }
}
