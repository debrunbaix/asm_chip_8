#include "raylib.h"
#include <stdlib.h>
#include <math.h>
#include "audio.h"

#define BEEP_FREQUENCY 440.0f
#define BEEP_SAMPLE_RATE 44100
#define BEEP_DURATION 0.1f

static int audio_initialized = 0;
static Sound beep_sound;
static int sound_playing = 0;

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

int init_audio(void)
{
    InitAudioDevice();
    if (IsAudioDeviceReady())
    {
        init_beep_sound();
        audio_initialized = 1;
        return 1;
    }
    return 0;
}

void play_beep(void)
{
    if (audio_initialized && !sound_playing)
    {
        PlaySound(beep_sound);
        sound_playing = 1;
    }
}

void stop_beep(void)
{
    if (sound_playing)
    {
        StopSound(beep_sound);
        sound_playing = 0;
    }
}

void cleanup_audio(void)
{
    if (audio_initialized)
    {
        UnloadSound(beep_sound);
        CloseAudioDevice();
        audio_initialized = 0;
    }
}
