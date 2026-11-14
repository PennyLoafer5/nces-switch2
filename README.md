# Nic Cage Eats Stuff — Switch 2 port

A Switch 2 port of [Cart1416/nces-wiiu](https://github.com/Cart1416/nces-wiiu),
the Wii U homebrew port of *Nic Cage Eats Stuff*.

It uses the public **ounce-devkit** (libounce, a libnx-compatible Switch 2
library) and devkitPro's Switch SDL2 portlibs. The game code is kept as close
to the Wii U original as possible; only platform-specific pieces were changed.
See [PORTING_NOTES.md](PORTING_NOTES.md) for the full explanation.

> **Status:** builds a Switch 2 `.nro`, boots, and is playable on real hardware.
> Controller enumeration, menu navigation, A/B labels, D-pad movement and pause
> were verified. See [PORTING_NOTES.md](PORTING_NOTES.md) for the details.

## Requirements

- devkitPro with the Switch toolchain:
  - `switch-dev`
  - `switch-zlib`
  - `dkp-toolchain-vars`
- ounce-devkit installed into `$DEVKITPRO` (tested with the `20261114`
  release; its version file reports `ounce-sdk 20261113` / `libounce db3f88a3`)
- Switch portlibs:
  - `switch-sdl2`
  - `switch-sdl2_image`
  - `switch-sdl2_mixer` (pulls the OGG/MP3/FLAC/Opus codec libraries)
  - `switch-sdl2_ttf`

The original Wii U toolchain (`wiiu-dev`, `wut`, `libromfs-wiiu`) is **not**
used by this project.

## Build

```sh
export DEVKITPRO=/opt/devkitpro
cd nces-switch2
make
```

Output:
- `nces-switch2.nro` 
- `nces-switch2.nacp` 
- `nces-switch2.elf` 

## Run

Use the NRO launcher available for your Switch 2 homebrew setup. The devkit
produces a standard NRO; this project does not assume a particular loader.
If your setup uses `nxlink`, the usual form is:

```sh
nxlink -s nces-switch2.nro
```

## What was ported

Only the platform boundary changed:

- `wut_rules` → `$(DEVKITPRO)/libounce/switch2_rules`
- `WHBProcInit` / `WHBProcIsRunning` / `WHBProcShutdown` →
  `romfsInit` + `appletMainLoop` + `romfsExit`
- `libromfs-wiiu` → libnx/libounce's built-in RomFS (`romfs:/`)
- `WHBLogPrint` → `svcOutputDebugString`
- Wii U raw joystick button numbers → SDL controller buttons
  (`SDL_CONTROLLER_BUTTON_BACK` / `START`)
- Switch controller enumeration → direct device-slot mapping, because the
  devkitPro Switch SDL2 driver always reports player index `-1`
- Switch face buttons → label-based mapping, so UI “A” is the physical A button
- RPX + WUHB metadata → NRO + NACP + icon + appended RomFS

The game logic, SDL rendering, asset paths and screen size are intentionally
untouched. No game assets were generated or modified; `romfs/` is used as-is.

## Credits and license

Original game and Wii U port: **Cart1416**.
Switch 2 port: **PennyLoafer**. MIT license, same as the original; see
[LICENSE](LICENSE).
