#include "raylib.h"
#include <stdint.h>
#include "display.h"
#include "audio.h"
#include "input.h"
#include "timers.h"

#define CHIP8_WIDTH 64
#define CHIP8_HEIGHT 32
#define SCALE 30
#define WINDOW_WIDTH (CHIP8_WIDTH * SCALE)
#define WINDOW_HEIGHT (CHIP8_HEIGHT * SCALE)

extern uint8_t DISPLAY[256];

static int display_initialized = 0;
static Color pixel_color = WHITE;

void set_pixel_color(uint32_t hex_color)
{
    // Format: 0xRRGGBB
    pixel_color.r = (hex_color >> 16) & 0xFF;
    pixel_color.g = (hex_color >> 8) & 0xFF;
    pixel_color.b = hex_color & 0xFF;
    pixel_color.a = 255;
}

int init_display(void)
{
    InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "CHIP-8 Emulator");
    SetTargetFPS(60);
    display_initialized = 1;

    init_audio();

    return 1;
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
    cleanup_audio();
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
