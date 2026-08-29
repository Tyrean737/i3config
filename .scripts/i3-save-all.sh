#!/usr/bin/env bash
# Saves all workspaces and runs the subsequent command (e.g. $shutdown or $reboot in i3 config)

dir="$HOME/.i3/i3-resurrect"
mkdir -p "$dir"
# record which workspaces existed, so restore knows what to loop over
i3-msg -t get_workspaces | jq -r '.[].name' > "$dir/workspaces.list"
while read -r ws; do
    i3-resurrect save -w "$ws"
done < "$dir/workspaces.list"

exec "$@"
