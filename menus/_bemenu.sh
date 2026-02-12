#!/usr/bin/env bash
set -euo pipefail

export BEMENU_BACKEND=wayland

exec bemenu \
  --fn 'BlexMono Nerd Font 14' \
  --bdr '#525252' \
  --tb '#000000' \
  --tf '#ffffff' \
  --fb '#000000' \
  --ff '#00ff00' \
  --nb '#000000' \
  --nf '#ffffff' \
  --hb '#333333' \
  --hf '#ffffff' \
  --ab '#000000' \
  --af '#ffffff' \
  --border 1 \
  --line-height 26 \
  --width-factor 0.3 \
  --list 20 \
  "$@"
