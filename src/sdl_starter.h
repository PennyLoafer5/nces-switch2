#pragma once

#include <SDL2/SDL.h>
#include <SDL2/SDL.h>
#include <SDL2/SDL_image.h>
#include <SDL2/SDL_mixer.h>
#include <SDL2/SDL_ttf.h>

// The Wii U build defined raw joystick button indices here.  The port uses
// SDL's SDL_CONTROLLER_BUTTON_* names instead, so those defines are gone.

const int SCREEN_WIDTH = 1920;
const int SCREEN_HEIGHT = 1080;

struct Sprite {
    SDL_Texture *texture;
    SDL_Rect bounds;
    float hv = 0.0f;
    float vv = 0.0f;
    float fx = 0.0f;
    float fy = 0.0f;
    float angle;
    bool protectingToken = false;
    bool invulnerable = false;
    bool immobile = false;
    bool evil = false;
    int evilTimer = 0;
    SDL_GameController* controller = nullptr;
    int controllerId = -1;
    bool previousInvulnerable = false;
};

int startSDLSystems(SDL_Window *window, SDL_Renderer *renderer);

Sprite loadSprite(SDL_Renderer* renderer, const char* filePath, int positionX, int positionY, float vx = 0.0f, float vy = 0.0f);

Mix_Chunk *loadSound(const char *filePath);

Mix_Music *loadMusic(const char *filePath);

void updateTextureText(SDL_Texture *&texture, const char *text, TTF_Font *&fontSquare, SDL_Renderer *renderer, SDL_Color fontColor = {255, 255, 255, 255});

void stopSDLSystems();
