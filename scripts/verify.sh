#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

image=codyssey-dev-station:1.0
prefix="codyssey-verify-$$"
ubuntu="$prefix-ubuntu"
web_a="$prefix-web-a"
web_b="$prefix-web-b"
bind="$prefix-bind"
volume_a="$prefix-volume-a"
volume_b="$prefix-volume-b"
volume="$prefix-data"
port_a="${PORT_A:-8080}"
port_b="${PORT_B:-8081}"
port_bind="${PORT_BIND:-8082}"
demo_dir=$(mktemp -d)
chmod 755 "$demo_dir"

cleanup() {
    if [[ "${KEEP_RESOURCES:-0}" != 1 ]]; then
        docker rm -f "$ubuntu" "$web_a" "$web_b" "$bind" "$volume_a" "$volume_b" >/dev/null 2>&1 || true
        docker volume rm "$volume" >/dev/null 2>&1 || true
        rm -r "$demo_dir"
    else
        printf '\n남겨 둔 리소스: %s / %s / %s\n' "$prefix" "$volume" "$demo_dir"
    fi
}
trap cleanup EXIT

run() {
    printf '$'
    printf ' %q' "$@"
    printf '\n'
    "$@"
}

wait_for_web() {
    curl -fsS --max-time 3 --retry 20 --retry-all-errors --retry-delay 1 "http://127.0.0.1:$1/health" >/dev/null
}

printf '\n## 실행 환경과 Docker 엔진\n'
run cat /etc/os-release
run bash --version
run git --version
run docker --version
run docker info --format 'Server={{.ServerVersion}} OS={{.OperatingSystem}} Driver={{.Driver}}'

printf '\n## 이미지 다운로드, 목록, 기본 컨테이너\n'
run docker pull hello-world:latest
run docker pull ubuntu:24.04
run docker images
run docker run --rm hello-world:latest
run docker run -id --name "$ubuntu" ubuntu:24.04 bash
run docker exec "$ubuntu" bash -c 'ls -d /etc /tmp; echo "exec shell exited independently"'
run docker inspect --format 'running after exec: {{.State.Running}}' "$ubuntu"
[[ $(docker inspect --format '{{.State.Running}}' "$ubuntu") == true ]]
printf '$ printf %%s\\n %q | timeout 20s docker attach %q\n' \
    'echo "attached to the main bash process"; exit 0' "$ubuntu"
printf '%s\n' 'echo "attached to the main bash process"; exit 0' | timeout 20s docker attach "$ubuntu"
run docker wait "$ubuntu"
run docker logs "$ubuntu"
run docker inspect --format 'running after attach and exit: {{.State.Running}}' "$ubuntu"
[[ $(docker inspect --format '{{.State.Running}} {{.State.ExitCode}}' "$ubuntu") == 'false 0' ]]
run docker ps -a --filter "name=$prefix"

printf '\n## 커스텀 이미지와 포트 매핑\n'
run docker build --progress=plain -t "$image" .
run docker images "$image"
run docker run -d -p "127.0.0.1:$port_a:80" --name "$web_a" "$image"
run docker run -d -p "127.0.0.1:$port_b:80" --name "$web_b" "$image"
for port in "$port_a" "$port_b"; do
    wait_for_web "$port"
    run curl -fsSi "http://127.0.0.1:$port/health"
    [[ $(curl -fsS "http://127.0.0.1:$port/health") == ok ]]
    run curl -fsS -o /dev/null -w '웹 페이지 HTTP %{http_code}\n' "http://127.0.0.1:$port/"
done
run docker ps --filter "name=$prefix"
run docker logs "$web_a"
run docker stats --no-stream "$web_a" "$web_b"

printf '\n## 바인드 마운트의 호스트 파일 변경 전후\n'
run cp bind-demo/index.html "$demo_dir/index.html"
run docker run -d -p "127.0.0.1:$port_bind:80" --name "$bind" \
    --mount "type=bind,source=$demo_dir,target=/usr/share/nginx/html,readonly" "$image"
wait_for_web "$port_bind"
before=$(curl -fsS "http://127.0.0.1:$port_bind/")
printf '$ curl -fsS http://127.0.0.1:%s/\n' "$port_bind"
printf '%s\n' "$before" | grep '<h1>'
[[ "$before" == *'bind mount: original'* ]]
run sed -i 's/bind mount: original/bind mount: updated/' "$demo_dir/index.html"
after=$(curl -fsS "http://127.0.0.1:$port_bind/")
printf '$ curl -fsS http://127.0.0.1:%s/\n' "$port_bind"
printf '%s\n' "$after" | grep '<h1>'
[[ "$after" == *'bind mount: updated'* ]]

printf '\n## 컨테이너 삭제 전후 볼륨 데이터\n'
run docker volume create "$volume"
run docker run -d --name "$volume_a" -v "$volume:/data" ubuntu:24.04 sleep 300
run docker exec "$volume_a" sh -c 'echo persistent-data > /data/proof.txt'
run docker exec "$volume_a" cat /data/proof.txt
run docker rm -f "$volume_a"
run docker run -d --name "$volume_b" -v "$volume:/data" ubuntu:24.04 sleep 300
run docker exec "$volume_b" cat /data/proof.txt
[[ $(docker exec "$volume_b" cat /data/proof.txt) == persistent-data ]]
run docker volume inspect "$volume" --format '{{.Name}} / {{.Driver}}'

printf '\n## 중지와 중지된 컨테이너 조회\n'
run docker stop "$web_b"
run docker ps -a --filter "name=$prefix"
printf '\nDocker 필수 검증 통과\n'
