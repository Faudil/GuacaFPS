#!/bin/sh
echo -ne '\033c\033]0;GuacaFPS\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/GuacaFps.x86_64" "$@"
