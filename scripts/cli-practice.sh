#!/usr/bin/env sh
set -eu

lab_root="${1:-./tmp/cli-practice}"
seed_path="$(pwd)/practice/seed.txt"

run() {
    printf '$'
    printf ' %s' "$@"
    printf '\n'
    "$@"
}

run pwd
run mkdir -p "$lab_root/source" "$lab_root/archive"
run cd "$lab_root"
run pwd
run touch source/empty.txt source/.hidden-note
run ls -la source archive
run cp "$seed_path" source/seed-copy.txt
run mv source/seed-copy.txt archive/renamed-note.txt
run cat archive/renamed-note.txt

printf '\n권한 변경 전\n'
run chmod 600 archive/renamed-note.txt
run chmod 700 archive
run ls -ld archive archive/renamed-note.txt
printf '\n권한 변경 후\n'
run chmod 644 archive/renamed-note.txt
run chmod 755 archive
run ls -ld archive archive/renamed-note.txt

run rm source/empty.txt
run ls -la source archive
