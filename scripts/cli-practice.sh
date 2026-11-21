#!/usr/bin/env sh
set -eu

lab_root="${1:-./tmp/cli-practice}"

printf '%s\n' '$ pwd'
pwd

printf '\n%s\n' '$ mkdir -p "$lab_root/source" "$lab_root/archive"'
mkdir -p "$lab_root/source" "$lab_root/archive"

printf '\n%s\n' '$ touch empty.txt .hidden-note'
touch "$lab_root/source/empty.txt" "$lab_root/source/.hidden-note"

printf '\n%s\n' '$ cp seed.txt seed-copy.txt'
cp practice/seed.txt "$lab_root/source/seed-copy.txt"

printf '\n%s\n' '$ mv seed-copy.txt archive/renamed-note.txt'
mv "$lab_root/source/seed-copy.txt" "$lab_root/archive/renamed-note.txt"

printf '\n%s\n' '$ cat archive/renamed-note.txt'
cat "$lab_root/archive/renamed-note.txt"

printf '\n%s\n' '$ chmod 644 file; chmod 755 directory'
chmod 644 "$lab_root/archive/renamed-note.txt"
chmod 755 "$lab_root/archive"
ls -ld "$lab_root/archive"
ls -l "$lab_root/archive/renamed-note.txt"

printf '\n%s\n' '$ ls -la source archive'
ls -la "$lab_root/source" "$lab_root/archive"

printf '\n%s\n' '$ rm empty.txt'
rm "$lab_root/source/empty.txt"

printf '\n%s\n' '$ find lab -maxdepth 2 -print'
find "$lab_root" -maxdepth 2 -print
