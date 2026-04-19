#!/usr/bin/env bash
set -euo pipefail

prompt=""

while (($#)); do
  case "$1" in
    -p|--prompt)
      shift
      prompt="${1:-}"
      ;;
  esac
  shift || true
done

exec fzf \
  --layout=reverse \
  --height=100% \
  --prompt "${prompt}> " \
  --pointer=">" \
  --marker="*" \
  --info=inline-right \
  --color="bg:#000000,bg+:#333333,fg:#ffffff,fg+:#ffffff,prompt:#ffffff,pointer:#6b8e23,marker:#6b8e23,hl:#6b8e23,hl+:#6b8e23"
