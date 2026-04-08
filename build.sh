#!/usr/bin/env sh

set -xe

wget https://github.com/agle/sb/releases/download/v0.0.1/sb
chmod +x sb

./sb -- --url https://agle.github.io  --title agle -o docs --prelude prelude.lua
