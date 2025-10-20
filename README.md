# Recovery Team (Arma 3)

[![GitHub Release](https://img.shields.io/github/v/release/BrettMayson/Arma_Recovery_Team?style=flat-square&label=Latest)](https://github.com/BrettMayson/Arma_Recovery_Team/releases)
[![GitHub Downloads](https://img.shields.io/github/downloads/BrettMayson/Arma_Recovery_Team/total?style=flat-square&label=Downloads)](https://github.com/BrettMayson/Arma_Recovery_Team/releases)

This is the full script source. Build `rt_core.pbo` with Arma 3 Tools → Addon Builder.
- Keep `mod.cpp` and `addons/rt_core/config.cpp` in sync with the same version string when you bump it.
- Source: `@RecoveryTeam\addons\rt_core`
- Output: `@RecoveryTeam\addons`
- Optional config: `@RecoveryTeam\userconfig\RT\RT_settings.sqf` (or root `userconfig\RT\RT_settings.sqf`)
- Optional CBA settings/keybind and Zeus module included.


## Signing (Optional but recommended)
### Windows
- The repository includes an empty `@RecoveryTeam/keys/` directory so HEMTT can stage the `.bikey` without error. Keep your private key outside of version control (see below).
- Run `make_pbo.bat`. If `keys\RecoveryTeam.biprivatekey` is missing, the script will create it using `DSCreateKey.exe`, sign the PBO with `DSSignFile.exe`, and copy the `.bikey` to `@RecoveryTeam\keys\`.

### Linux (Wine)
- Run `./make_pbo.sh`. Set env vars if your paths differ:
  ```bash
  WINE_BIN=wine TOOLS_DIR="$HOME/.local/share/Steam/steamapps/common/Arma 3 Tools" ./make_pbo.sh
  ```
- The script builds via AddonBuilder, creates a key if missing, signs via DSSignFile, and copies the `.bikey` into `@RecoveryTeam/keys/`.
- In CI you can provide a base64-encoded private key via `$BIPRIVATEKEY_BASE64` (or `$BIPRIVATEKEY`) and the script will write it to `keys/RecoveryTeam.biprivatekey` before signing.

> Keep your **.biprivatekey** secret. Distribute only the `.bikey` with your mod.


## HEMTT Build (cross‑platform)
1) Install HEMTT: https://hemtt.dev (or `cargo install hemtt`)
2) From this folder, run:
   ```bash
   hemtt build       # builds PBOs into .hemttout
   hemtt release     # creates a ready‑to‑use @RecoveryTeam in ./dist (and signs if keys present)
   ```
3) For signing: put your private key at `keys/RecoveryTeam.biprivatekey` before `hemtt release`.
4) The public key (`.bikey`) will be emitted into `@RecoveryTeam/keys/` inside the release.

Notes:
- Source for the PBO is under `addons/rt_core/` (mirrors the copy in `@RecoveryTeam/addons/rt_core`). 
- `userconfig/RT/RT_settings.sqf` is included in the release.
