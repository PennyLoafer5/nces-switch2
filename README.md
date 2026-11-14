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

| File | Purpose |
| --- | --- |
| `nces-switch2.nro` | Homebrew executable with icon, NACP metadata and RomFS |
| `nces-switch2.nacp` | Generated metadata (also embedded in the NRO) |
| `nces-switch2.elf` | Unstripped AArch64 ELF for debugging |

`make clean` removes all three plus `build/`.

## Custom icon and metadata

The top of the `Makefile` controls the NACP metadata and the icon:

```make
APP_TITLE   := Nic Cage Eats Stuff
APP_AUTHOR  := Cart1416
APP_VERSION := 1.0.0
ICON        := icon.png
```

- `APP_TITLE` is the name shown by the launcher.
- `APP_AUTHOR` is the author string stored in the NACP.
- `APP_VERSION` is a free-form string; the NACP version field is 16 bytes, so
  keep it to 15 characters or fewer.
- `ICON` is a path relative to the project root.

`elf2nro` embeds the icon file byte-for-byte; it does not resize or convert it.
The standard Switch homebrew menu decodes JPEG icons and expects 256×256, so a
custom icon should be a square 256×256 JPEG (for example `ICON := icon.jpg`).
The original `icon.png` is a 128×128 PNG and is embedded as-is.

After changing the icon or metadata, rebuild:

```sh
export DEVKITPRO=/opt/devkitpro
cd nces-switch2
make clean && make
```

`make clean` is required after an icon change because the NRO rule does not
list the icon as a dependency. The rebuilt `nces-switch2.nro` is written to the
project root.

## Run

Use the NRO launcher available for your Switch 2 homebrew setup. The devkit
produces a standard NRO; this project does not assume a particular loader.
If your setup uses `nxlink`, the usual form is:

```sh
nxlink -s nces-switch2.nro
```

The game is controller-only:

- **A** — select / hold for invincibility
- **D-Pad or left stick** — move
- **Plus** — pause (in a game)
- **Minus** — back to game select

The Switch controller is remapped to label order, so the on-screen **A** means
the physical A button (not the bottom face button).

## Project layout

```
nces-switch2/
├── Makefile              # Switch 2 build, NRO metadata, RomFS
├── include/
│   └── platform.h        # Wii U / Switch 2 process, RomFS and logging shim
├── src/
│   ├── main.cpp          # game, with platform calls shimmed
│   ├── sdl_starter.cpp   # SDL init/asset helpers + Switch button mapping
│   └── sdl_starter.h     # SDL helpers (Wii U button defines removed)
├── romfs/                # original game assets, unchanged
├── icon.png              # launcher icon (original; see “Custom icon and metadata”)
└── LICENSE               # original MIT license
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
The launcher icon is the original file and can be replaced independently. See
`PORTING_NOTES.md` for the controller details.

## Credits and license

Original game and Wii U port: **Cart1416**.
Switch 2 port: this project. MIT license, same as the original; see
[LICENSE](LICENSE).
