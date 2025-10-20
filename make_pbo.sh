#!/usr/bin/env bash
set -euo pipefail

# ────────────────────────────────────────────────────────────────────────────────
# Recovery Team - PBO Build & Signing (Linux)
# Requirements:
#   - wine (or proton) installed
#   - Arma 3 Tools installed via Steam (accessible to wine)
#   - Optional: place your .biprivatekey in ./keys/
# Customize the paths below if your setup differs.
# ────────────────────────────────────────────────────────────────────────────────

# EDIT ME: Wine binary and Arma 3 Tools paths
WINE_BIN="${WINE_BIN:-wine}"
TOOLS_DIR="${TOOLS_DIR:-$HOME/.local/share/Steam/steamapps/common/Arma 3 Tools}"
ADDON_BUILDER_EXE="${ADDON_BUILDER_EXE:-$TOOLS_DIR/AddonBuilder/AddonBuilder.exe}"
DSSIGN_EXE="${DSSIGN_EXE:-$TOOLS_DIR/DSSignFile/DSSignFile.exe}"
DSCREATE_EXE="${DSCREATE_EXE:-$TOOLS_DIR/DSSignFile/DSCreateKey.exe}"

# Mod paths (relative to this script)
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_DIR="$ROOT_DIR/@RecoveryTeam/addons/rt_core"
DEST_DIR="$ROOT_DIR/@RecoveryTeam/addons"
KEYS_DIR="$ROOT_DIR/keys"
MOD_KEYS_DIR="$ROOT_DIR/@RecoveryTeam/keys"

# Config
KEY_NAME="${KEY_NAME:-RecoveryTeam}"               # The name for your key pair
BIPRIVATE="$KEYS_DIR/${KEY_NAME}.biprivatekey"
BIKEY="$KEYS_DIR/${KEY_NAME}.bikey"

# Inject private key from CI if provided as base64
if [[ -n "${BIPRIVATEKEY_BASE64:-}" || -n "${BIPRIVATEKEY:-}" ]]; then
  echo "==> Writing private key from environment secret"
  KEY_B64="${BIPRIVATEKEY_BASE64:-${BIPRIVATEKEY:-}}"
  printf '%s' "$KEY_B64" | base64 -d >"$BIPRIVATE"
  chmod 600 "$BIPRIVATE"
fi

echo "==> Building PBO via AddonBuilder under Wine"
echo "    SRC:  $SRC_DIR"
echo "    DEST: $DEST_DIR"
mkdir -p "$DEST_DIR" "$KEYS_DIR" "$MOD_KEYS_DIR"

# Build PBO
"$WINE_BIN" "$ADDON_BUILDER_EXE" "$SRC_DIR" "$DEST_DIR" \
  -prefix=rt_core \
  -include=*.sqf;*.cpp;*.hpp \
  -binarize \
  -clear \
  -temp="$TMPDIR/ArmaBuildTemp"

PBO="$DEST_DIR/rt_core.pbo"
test -f "$PBO" || { echo "ERROR: PBO not built at $PBO"; exit 1; }
echo "==> Built: $PBO"

# Create key if missing
if [[ ! -f "$BIPRIVATE" ]]; then
  echo "==> Private key not found; creating new key pair: $KEY_NAME"
  "$WINE_BIN" "$DSCREATE_EXE" "$BIPRIVATE" "$BIKEY"
fi

# Sign PBO
echo "==> Signing PBO with $BIPRIVATE"
"$WINE_BIN" "$DSSIGN_EXE" "$BIPRIVATE" "$PBO"

# Deploy bikey into mod's /keys (what servers/clients need)
cp -f "$BIKEY" "$MOD_KEYS_DIR/"
echo "==> Copied public key to: $MOD_KEYS_DIR/$(basename "$BIKEY")"

echo "✅ Done. Load @RecoveryTeam as a local mod; share the .bikey with servers."
