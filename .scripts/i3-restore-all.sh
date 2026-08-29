#!/usr/bin/env bash
dir="$HOME/.i3/i3-resurrect"
[ -r "$dir/workspaces.list" ] || exit 0
while read -r ws; do
    i3-resurrect restore -w "$ws"
    sleep 1   # give windows time to map before the next workspace
done < "$dir/workspaces.list"
