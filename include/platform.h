#pragma once

// -----------------------------------------------------------------------------
// Small platform shim for the Nic Cage Eats Stuff port.
//
// The game itself only needs four platform services:
//   * process / applet lifetime
//   * mounting the read-only ROM filesystem
//   * a working directory on that filesystem
//   * debug logging
//
// Keeping those in one header means the game code is almost identical on Wii U
// (wut) and Switch 2 (libounce).  __SWITCH2__ is defined by switch2_rules;
// __WIIU__/__WUT__ are defined by the Wii U toolchain.
// -----------------------------------------------------------------------------

#if defined(__SWITCH2__) || defined(__SWITCH__)

#include <switch.h>
#include <unistd.h>
#include <cstring>

static inline bool platformInit(void)
{
    // libnx/libounce mount the NRO's appended RomFS at "romfs:/".
    return R_SUCCEEDED(romfsInit());
}

static inline void platformLogInit(void)
{
    // Switch debug output goes through the debug SVC (visible to a debugger)
    // or SDL's logger.  Nothing to initialise here.
}

static inline void platformShutdown(void)
{
    romfsExit();
}

static inline bool platformRunning(void)
{
    // appletMainLoop() also pumps applet messages: HOME menu, sleep, exit.
    return appletMainLoop();
}

static inline void platformLog(const char *message)
{
    if (message != nullptr)
        svcOutputDebugString(message, strlen(message));
}

// The devkitPro Switch SDL2 joystick driver exposes eight fixed device slots
// and always returns -1 from SDL_GameControllerGetPlayerIndex().  Ask libnx
// whether the physical pad for a slot is actually connected so the game does
// not create five fake players.  Slot 0 is the system default pad (player 1);
// slots 1..4 correspond to pads 2..5.
static inline bool platformControllerConnected(int deviceIndex)
{
    PadState pad;
    if (deviceIndex == 0) {
        padInitializeDefault(&pad);
    } else {
        padInitialize(&pad, static_cast<HidNpadIdType>(HidNpadIdType_No1 + deviceIndex));
    }
    padUpdate(&pad);
    return padIsConnected(&pad);
}

#elif defined(__WIIU__) || defined(__WUT__)

#include <romfs-wiiu.h>
#include <whb/proc.h>
#include <whb/log.h>
#include <whb/log_cafe.h>
#include <whb/log_udp.h>
#include <unistd.h>

static inline bool platformInit(void)
{
    WHBProcInit();
    romfsInit();
    return true;
}

static inline void platformLogInit(void)
{
    WHBLogCafeInit();
    WHBLogUdpInit();
}

static inline void platformShutdown(void)
{
    romfsExit();
    WHBProcShutdown();
}

static inline bool platformRunning(void)
{
    return WHBProcIsRunning();
}

static inline void platformLog(const char *message)
{
    if (message != nullptr)
        WHBLogPrintf("%s", message);
}

// The Wii U build always had a GamePad, so keep the original assumption.
static inline bool platformControllerConnected(int)
{
    return true;
}

#else
#error "platform.h: define __SWITCH2__/__SWITCH__ or __WIIU__/__WUT__"
#endif
