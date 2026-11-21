# 터미널 조작 및 권한 실습 로그

실행 일시: 2026-11-21 (KST)

셸: Git Bash

재현 명령: `./scripts/cli-practice.sh`

아래는 실제 실행 출력입니다.

```text
$ pwd
/c/Users/nemsk/Documents/ChatGPT/코디세이 올인원 E1-1

$ mkdir -p "$lab_root/source" "$lab_root/archive"

$ touch empty.txt .hidden-note

$ cp seed.txt seed-copy.txt

$ mv seed-copy.txt archive/renamed-note.txt

$ cat archive/renamed-note.txt
Codyssey CLI practice seed file.
This file is copied, renamed, read, and permission-checked by scripts/cli-practice.sh.

$ chmod 644 file; chmod 755 directory
drwxr-xr-x 1 nemsk 197609 0 Nov 21 17:47 ./tmp/cli-practice/archive
-rw-r--r-- 1 nemsk 197609 121 Nov 21 17:47 ./tmp/cli-practice/archive/renamed-note.txt

$ ls -la source archive
./tmp/cli-practice/archive:
total 1
drwxr-xr-x 1 nemsk 197609   0 Nov 21 17:47 .
drwxr-xr-x 1 nemsk 197609   0 Nov 21 17:47 ..
-rw-r--r-- 1 nemsk 197609 121 Nov 21 17:47 renamed-note.txt

./tmp/cli-practice/source:
total 0
drwxr-xr-x 1 nemsk 197609 0 Nov 21 17:47 .
drwxr-xr-x 1 nemsk 197609 0 Nov 21 17:47 ..
-rw-r--r-- 1 nemsk 197609 0 Nov 21 17:47 .hidden-note
-rw-r--r-- 1 nemsk 197609 0 Nov 21 17:47 empty.txt

$ rm empty.txt

$ find lab -maxdepth 2 -print
./tmp/cli-practice
./tmp/cli-practice/archive
./tmp/cli-practice/archive/renamed-note.txt
./tmp/cli-practice/source
./tmp/cli-practice/source/.hidden-note
```

## 권한 해석

- `644` = 소유자 `rw-`(읽기+쓰기), 그룹 `r--`(읽기), 기타 사용자 `r--`(읽기)
- `755` = 소유자 `rwx`(읽기+쓰기+실행), 그룹 `r-x`, 기타 사용자 `r-x`
- 디렉터리의 실행(`x`) 권한은 그 디렉터리 안으로 진입하고 항목에 접근하기 위해 필요합니다.
- `777`은 모든 사용자에게 쓰기까지 허용하므로 공유 임시 디렉터리 같은 특별한 경우가 아니라면 피합니다.

이 실습은 Git Bash의 POSIX 호환 명령으로 수행했습니다. Windows NTFS의 최종 접근 제어는 Windows ACL의 영향도 받으므로 Linux 서버에서는 같은 명령을 다시 확인해야 합니다.
