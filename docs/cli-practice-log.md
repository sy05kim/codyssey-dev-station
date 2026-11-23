# 터미널 조작 및 권한 실습 로그

실행 환경은 Debian 13의 Bash 터미널입니다. 실습 스크립트는 POSIX 셸로 실행했습니다. 공유 경로와 소유자 정보는 `<workspace>`, `<user>`로 표시했습니다.

```text
$ sh scripts/cli-practice.sh
$ pwd
<workspace>
$ mkdir -p ./tmp/cli-practice/source ./tmp/cli-practice/archive
$ cd ./tmp/cli-practice
$ pwd
<workspace>/tmp/cli-practice
$ touch source/empty.txt source/.hidden-note
$ ls -la source archive
archive:
total 8
drwxr-xr-x 2 <user> <user> 4096 Nov 23 19:52 .
drwxr-xr-x 4 <user> <user> 4096 Nov 23 19:52 ..

source:
total 8
drwxr-xr-x 2 <user> <user> 4096 Nov 23 19:52 .
drwxr-xr-x 4 <user> <user> 4096 Nov 23 19:52 ..
-rw-r--r-- 1 <user> <user>    0 Nov 23 19:52 .hidden-note
-rw-r--r-- 1 <user> <user>    0 Nov 23 19:52 empty.txt
$ cp <workspace>/practice/seed.txt source/seed-copy.txt
$ mv source/seed-copy.txt archive/renamed-note.txt
$ cat archive/renamed-note.txt
Codyssey CLI practice seed file.
This file is copied, renamed, read, and permission-checked by scripts/cli-practice.sh.

권한 변경 전
$ chmod 600 archive/renamed-note.txt
$ chmod 700 archive
$ ls -ld archive archive/renamed-note.txt
drwx------ 2 <user> <user> 4096 Nov 23 19:52 archive
-rw------- 1 <user> <user>  120 Nov 23 19:52 archive/renamed-note.txt

권한 변경 후
$ chmod 644 archive/renamed-note.txt
$ chmod 755 archive
$ ls -ld archive archive/renamed-note.txt
drwxr-xr-x 2 <user> <user> 4096 Nov 23 19:52 archive
-rw-r--r-- 1 <user> <user>  120 Nov 23 19:52 archive/renamed-note.txt
$ rm source/empty.txt
$ ls -la source archive
archive:
total 12
drwxr-xr-x 2 <user> <user> 4096 Nov 23 19:52 .
drwxr-xr-x 4 <user> <user> 4096 Nov 23 19:52 ..
-rw-r--r-- 1 <user> <user>  120 Nov 23 19:52 renamed-note.txt

source:
total 8
drwxr-xr-x 2 <user> <user> 4096 Nov 23 19:52 .
drwxr-xr-x 4 <user> <user> 4096 Nov 23 19:52 ..
-rw-r--r-- 1 <user> <user>    0 Nov 23 19:52 .hidden-note
```

## 경로와 권한 해석

- 절대 경로는 루트 `/`부터 시작합니다. 상대 경로 `archive/renamed-note.txt`는 현재 위치인 실습 디렉터리를 기준으로 해석합니다.
- 읽기(`r`)는 4, 쓰기(`w`)는 2, 실행 또는 디렉터리 탐색(`x`)은 1입니다. 소유자, 그룹, 기타 사용자 순서로 각 숫자를 해석합니다.
- 파일 `600` → `644`는 소유자 읽기·쓰기를 유지하면서 그룹과 기타 사용자에게 읽기를 허용합니다.
- 디렉터리 `700` → `755`는 그룹과 기타 사용자에게 목록 읽기와 디렉터리 안의 항목에 접근하는 권한을 더합니다.
