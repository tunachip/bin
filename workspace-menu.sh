#!/usr/bin/env bash
set -euo pipefail

MENU="${HOME}/.local/bin/menus/_bemenu.sh"
MODE="${1:-switch}"
MAX_APPS=6
MAX_LEN=64

if [[ ! -x "$MENU" ]]; then
  exit 1
fi

if ! command -v swaymsg >/dev/null 2>&1 || ! command -v jq >/dev/null 2>&1; then
  exit 1
fi

readarray -t rows < <(
  swaymsg -t get_tree \
    | jq -r '
      def walknodes: recurse(.nodes[]?, .floating_nodes[]?);
      [
        walknodes
        | select(.type == "workspace" and .name != "__i3_scratch")
        | {
            name,
            num,
            focused,
            apps: [
              walknodes
              | select((.nodes | length) == 0 and (.floating_nodes | length) == 0)
              | select(.window != null or .app_id != null or .window_properties.class != null)
              | (.app_id // .window_properties.class // .name // "app")
            ]
          }
      ]
      | sort_by(.num, .name)
      | .[]
      | [.focused, .num, .name, (.apps | join(","))]
      | @tsv
    '
)

if [[ ${#rows[@]} -eq 0 ]]; then
  exit 0
fi

labels=()
targets=()
current_target=""

for row in "${rows[@]}"; do
  IFS=$'\t' read -r focused num name apps_csv <<<"$row"

  target="$name"
  if [[ "$focused" == "true" ]]; then
    current_target="$target"
  fi

  shown_num="$num"
  if [[ "$num" -lt 0 ]]; then
    shown_num="$name"
  fi

  apps_display="(empty)"
  if [[ -n "$apps_csv" ]]; then
    IFS=',' read -r -a apps <<<"$apps_csv"
    if [[ ${#apps[@]} -gt $MAX_APPS ]]; then
      apps=("${apps[@]:0:$MAX_APPS}")
      apps_display="${apps[*]// /, }, ..."
    else
      apps_display="${apps[*]// /, }"
    fi
  fi

  if [[ ${#apps_display} -gt $MAX_LEN ]]; then
    apps_display="${apps_display:0:$((MAX_LEN - 3))}..."
  fi

  label="${shown_num}: ${apps_display}"
  if [[ "$target" == "$current_target" ]]; then
    label+="  [current]"
  fi

  labels+=("$label")
  targets+=("$target")
done

prompt="workspace"
if [[ "$MODE" == "move" ]]; then
  prompt="move"
fi

choice="$({ printf '%s\n' "${labels[@]}"; } | "$MENU" -p "$prompt")" || exit 0
[[ -z "${choice:-}" ]] && exit 0

selected_index=-1
for i in "${!labels[@]}"; do
  if [[ "${labels[$i]}" == "$choice" ]]; then
    selected_index=$i
    break
  fi
done

[[ $selected_index -lt 0 ]] && exit 0
selected_target="${targets[$selected_index]}"

case "$MODE" in
  switch)
    swaymsg "workspace ${selected_target}" >/dev/null
    ;;
  move)
    swaymsg "move container to workspace ${selected_target}" >/dev/null
    swaymsg "workspace ${selected_target}" >/dev/null
    ;;
  *)
    exit 1
    ;;
esac
