#!/bin/sh
echo -ne '\033c\033]0;BattleShips_Online\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/battleships_server.arm64" "$@"
