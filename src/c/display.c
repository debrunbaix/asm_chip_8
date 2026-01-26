#include "raylib.h"
#include <stdint.h>
#include <stdlib.h>
#include <math.h>

#define CHIP8_WIDTH 64
#define CHIP8_HEIGHT 32
#define SCALE 10
#define WINDOW_WIDTH (CHIP8_WIDTH * SCALE)
#define WINDOW_HEIGHT (CHIP8_HEIGHT * SCALE)

#define BEEP_FREQUENCY 440.0f
#define BEEP_SAMPLE_RATE 44100
#define BEEP_DURATION 0.1f

extern uint8_t DISPLAY[256];
extern uint8_t KEYPAD[16];
extern uint8_t DELAY_TIMER;
extern uint8_t SOUND_TIMER;

static int display_initialized = 0;
static int audio_initialized = 0;
static Color pixel_color = WHITE;
static Sound beep_sound;
static int sound_playing = 0;

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

void set_pixel_color(uint32_t hex_color)
{
    // Format: 0xRRGGBB
    pixel_color.r = (hex_color >> 16) & 0xFF;
    pixel_color.g = (hex_color >> 8) & 0xFF;
    pixel_color.b = hex_color & 0xFF;
    pixel_color.a = 255;
}

static void init_beep_sound(void)
{
    int sample_count = (int)(BEEP_SAMPLE_RATE * BEEP_DURATION);
    Wave wave = {
        .frameCount = sample_count,
        .sampleRate = BEEP_SAMPLE_RATE,
        .sampleSize = 16,
        .channels = 1,
        .data = malloc(sample_count * sizeof(short))
    };

    short *samples = (short *)wave.data;
    for (int i = 0; i < sample_count; i++)
    {
        float t = (float)i / BEEP_SAMPLE_RATE;
        samples[i] = (short)(sinf(2.0f * 3.14159f * BEEP_FREQUENCY * t) * 32000);
    }

    beep_sound = LoadSoundFromWave(wave);
    free(wave.data);
}

int init_display(void)
{
    InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "CHIP-8 Emulator");
    SetTargetFPS(60);
    display_initialized = 1;

    InitAudioDevice();
    if (IsAudioDeviceReady())
    {
        init_beep_sound();
        audio_initialized = 1;
    }

    return 1;
}

void update_keypad(void)
{
    if (!display_initialized)
        return;

    for (int i = 0; i < 16; i++)
    {
        KEYPAD[i] = IsKeyDown(key_map[i]) ? 1 : 0;
    }
}

void update_timers(void)
{
    if (DELAY_TIMER > 0)
    {
        DELAY_TIMER--;
    }

    if (SOUND_TIMER > 0)
    {
        if (audio_initialized && !sound_playing)
        {
            PlaySound(beep_sound);
            sound_playing = 1;
        }
        SOUND_TIMER--;
    }
    else
    {
        if (sound_playing)
        {
            StopSound(beep_sound);
            sound_playing = 0;
        }
    }
}

void render_display(void)
{
    if (!display_initialized)
        return;

    // Mettre a jour l'etat du clavier
    update_keypad();

    // Mettre a jour les timers (60Hz)
    update_timers();

    BeginDrawing();
    ClearBackground(BLACK);

    for (int y = 0; y < CHIP8_HEIGHT; y++)
    {
        for (int x = 0; x < CHIP8_WIDTH; x++)
        {
            int byte_index = (y * CHIP8_WIDTH + x) / 8;
            int bit_index = 7 - (x % 8);

            if ((DISPLAY[byte_index] >> bit_index) & 1)
            {
                DrawRectangle(x * SCALE, y * SCALE, SCALE, SCALE, pixel_color);
            }
        }
    }

    EndDrawing();
}

int check_quit(void)
{
    if (!display_initialized)
        return 1;
    return WindowShouldClose();
}

void cleanup_display(void)
{
    if (audio_initialized)
    {
        UnloadSound(beep_sound);
        CloseAudioDevice();
        audio_initialized = 0;
    }
    if (display_initialized)
    {
        CloseWindow();
        display_initialized = 0;
    }
}

void delay_ms(int ms)
{
    WaitTime((double)ms / 1000.0);
}
