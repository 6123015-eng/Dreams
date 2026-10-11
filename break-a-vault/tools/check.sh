#!/usr/bin/env bash
# Valida y renderiza uno o más martillos:  tools/check.sh RustyHammer [SafeCracker ...]
# 1) lune build (valida propiedades/enums reales de Roblox, soldaduras, conteos) → dist/hammers.json
# 2) render → tools/render/out/<Id>.png (vistas hero/profile/back/head)
set -euo pipefail
cd "$(dirname "$0")/.."
LUNE="${LUNE:-$HOME/.cargo/bin/lune}"
if [ $# -eq 0 ]; then echo "uso: tools/check.sh <HammerId> [...]"; exit 2; fi
IDS=$(IFS=,; echo "$*")
JSON="dist/check_$(echo "$IDS" | tr ',' '_' | cut -c1-60).json"
"$LUNE" run tools/build.luau -- --only "$IDS" --json "$JSON"
HAMMERS_JSON="$JSON" node tools/render/render.mjs --no-sheet "$@"
