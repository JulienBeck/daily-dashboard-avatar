#!/usr/bin/env bash
set -euo pipefail
# BLENDER: Blender 4.5 LTS with MPFB2 and its system assets installed.
# DASHBOARD: checkout of daily-dashboard; its item catalog decides what gets built.
blender=${BLENDER:-blender}
root=$(cd "$(dirname "$0")" && pwd)
dashboard=$(cd "${DASHBOARD:-$root/../daily-dashboard}" && pwd)
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
(cd "$dashboard" && npx tsx -e "import { ITEMS } from './src/shared/avatar.ts'; console.log(JSON.stringify(ITEMS))") > "$work/items.json"
mkdir -p "$work/icons"
run() { "$blender" -b --python-exit-code 1 --python "$root/blender/build.py" -- items "$work/items.json" "$@"; }
run body female glb "$work/female.glb"
run body male glb "$work/male.glb" icons "$work/icons"
cd "$root"
rm -rf public
mkdir -p public/icons
# Meshopt compression; -kn/-km keep the names the dashboard looks up. -vpf keeps
# float positions: quantised ones leave the skinned figure invisible in three.js.
for body in female male; do
  npx --no-install gltfpack -i "$work/$body.glb" -o "public/$body.glb" -cc -kn -km -ke -vpf
done
cp "$work"/icons/*.png public/icons/
ls -lR public
