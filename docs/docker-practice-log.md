# Docker 실습 로그

GitHub Actions의 Ubuntu 24.04 환경에서 실행한 Docker 검증 결과입니다.
[원본 실행](https://github.com/sy05kim/codyssey-dev-station/actions/runs/45161608202) · [검증 스크립트](../scripts/verify.sh) · [브라우저 접속 캡처](browser-8080.png)

## 실행 환경과 Docker 엔진

```text
$ cat /etc/os-release
PRETTY_NAME="Ubuntu 24.04.5 LTS"
NAME="Ubuntu"
VERSION_ID="24.04"
VERSION="24.04.5 LTS (Noble Numbat)"
VERSION_CODENAME=noble
ID=ubuntu
ID_LIKE=debian
HOME_URL="https://www.ubuntu.com/"
SUPPORT_URL="https://help.ubuntu.com/"
BUG_REPORT_URL="https://bugs.launchpad.net/ubuntu/"
PRIVACY_POLICY_URL="https://www.ubuntu.com/legal/terms-and-policies/privacy-policy"
UBUNTU_CODENAME=noble
LOGO=ubuntu-logo
$ bash --version
GNU bash, version 5.2.21(1)-release (x86_64-pc-linux-gnu)
Copyright (C) 2022 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>

This is free software; you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.
$ git --version
git version 2.56.1
$ docker --version
Docker version 28.0.4, build b8034c0
$ docker info --format Server=\{\{.ServerVersion\}\}\ OS=\{\{.OperatingSystem\}\}\ Driver=\{\{.Driver\}\}
Server=28.0.4 OS=Ubuntu 24.04.5 LTS Driver=overlay2
```

## 이미지 다운로드, 목록, 기본 컨테이너

```text
$ docker pull hello-world:latest
latest: Pulling from library/hello-world
4f55086f7dd0: Pulling fs layer
4f55086f7dd0: Verifying Checksum
4f55086f7dd0: Download complete
4f55086f7dd0: Pull complete
Digest: sha256:1e4c05b897a751332ce85c7e9449da2d93514ea2dea6dbb0e2753c9e949b2bfa
Status: Downloaded newer image for hello-world:latest
docker.io/library/hello-world:latest
$ docker pull ubuntu:24.04
24.04: Pulling from library/ubuntu
8e8df94085bf: Pulling fs layer
8e8df94085bf: Verifying Checksum
8e8df94085bf: Download complete
8e8df94085bf: Pull complete
Digest: sha256:9c7f200c07e3d4a03e7249d2c16bf66a51120fb876aa2242cf31451412543289
Status: Downloaded newer image for ubuntu:24.04
docker.io/library/ubuntu:24.04
$ docker images
REPOSITORY                                   TAG       IMAGE ID       CREATED        SIZE
ghcr.io/dependabot/dependabot-updater-core   latest    d0683050653b   7 days ago     852MB
ghcr.io/github/gh-aw-mcpg                    latest    4a62ff99bb92   8 days ago     186MB
ghcr.io/github/gh-aw-firewall/squid          latest    7c8c9dff3252   8 days ago     57.5MB
ghcr.io/github/gh-aw-firewall/agent          latest    e1cc8445e3f5   8 days ago     1.04GB
ghcr.io/github/gh-aw-firewall/api-proxy      latest    0e559b513243   8 days ago     377MB
ubuntu                                       24.04     2b147973fd86   12 days ago    78.2MB
ghcr.io/github/github-mcp-server             latest    84e9c718c0fa   2 weeks ago    50.2MB
hello-world                                  latest    e2ac70e7319a   8 months ago   10.1kB
$ docker run --rm hello-world:latest

Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
    (amd64)
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.

To try something more ambitious, you can run an Ubuntu container with:
 $ docker run -it ubuntu bash

Share images, automate workflows, and more with a free Docker ID:
 https://hub.docker.com/

For more examples and ideas, visit:
 https://docs.docker.com/get-started/

$ docker run -id --name codyssey-verify-2019-ubuntu ubuntu:24.04 bash
9d0939cc71175bebada6e7eb1cf6c3cf1345b1cae90fc7e77e1d4d5bbdd05fa6
$ docker exec codyssey-verify-2019-ubuntu bash -c ls\ -d\ /etc\ /tmp\;\ echo\ \"exec\ shell\ exited\ independently\"
/etc
/tmp
exec shell exited independently
$ docker inspect --format running\ after\ exec:\ \{\{.State.Running\}\} codyssey-verify-2019-ubuntu
running after exec: true
$ printf %s\n echo\ \"attached\ to\ the\ main\ bash\ process\"\;\ exit\ 0 | timeout 20s docker attach codyssey-verify-2019-ubuntu
$ docker wait codyssey-verify-2019-ubuntu
0
$ docker logs codyssey-verify-2019-ubuntu
attached to the main bash process
$ docker inspect --format running\ after\ attach\ and\ exit:\ \{\{.State.Running\}\} codyssey-verify-2019-ubuntu
running after attach and exit: false
$ docker ps -a --filter name=codyssey-verify-2019
CONTAINER ID   IMAGE          COMMAND   CREATED                  STATUS                              PORTS     NAMES
9d0939cc7117   ubuntu:24.04   "bash"    Less than a second ago   Exited (0) Less than a second ago             codyssey-verify-2019-ubuntu
```

## 커스텀 이미지와 포트 매핑

```text
$ docker build --progress=plain -t codyssey-dev-station:1.0 .
#0 building with "default" instance using docker driver

#1 [internal] load build definition from Dockerfile
#1 transferring dockerfile: 554B done
#1 DONE 0.0s

#2 [internal] load metadata for docker.io/library/nginx:alpine
#2 ...

#3 [auth] library/nginx:pull token for registry-1.docker.io
#3 DONE 0.0s

#2 [internal] load metadata for docker.io/library/nginx:alpine
#2 DONE 0.7s

#4 [internal] load .dockerignore
#4 transferring context: 104B done
#4 DONE 0.0s

#5 [internal] load build context
#5 transferring context: 17.81kB done
#5 DONE 0.0s

#6 [1/4] FROM docker.io/library/nginx:alpine@sha256:fb4658584bd9a916ffb6f6e365f97c25cfdb2923801f551ea08356e695f14ff7
#6 resolve docker.io/library/nginx:alpine@sha256:fb4658584bd9a916ffb6f6e365f97c25cfdb2923801f551ea08356e695f14ff7 done
#6 sha256:e68702efeaad0be9ced2b4d1cedb62cd15f5d51865d913955a883f653cd9e117 2.50kB / 2.50kB done
#6 sha256:62d1c420c34ae91f7bffd349903cd6846806b835129c8b7ba2da28b3be323cd1 12.32kB / 12.32kB done
#6 sha256:77a3bfea78f562fc46a238affde2e413f44ebe98eb6accd78acc9aade0711eed 1.94MB / 1.94MB 0.2s done
#6 sha256:04c3905a997c5ada93c8e4ad6c8d593e04c5ad4efa87a648a72f34138ea47117 627B / 627B 0.1s done
#6 sha256:fb4658584bd9a916ffb6f6e365f97c25cfdb2923801f551ea08356e695f14ff7 10.33kB / 10.33kB done
#6 extracting sha256:881fc932939efef04ca120ad44bbd2c0917851eb247aa4995428afb1e80ede17 0.1s done
#6 extracting sha256:77a3bfea78f562fc46a238affde2e413f44ebe98eb6accd78acc9aade0711eed 0.0s done
#6 sha256:881fc932939efef04ca120ad44bbd2c0917851eb247aa4995428afb1e80ede17 3.85MB / 3.85MB 0.1s done
#6 sha256:4c8c172c658661b7927fad4ab766c7e6c597d83400a3ed3f2e484c5940b4c56a 0B / 404B 0.2s
#6 sha256:61d8f4c85a745813b78f7b3ea04d0268fd196753e0964ac6cd3f55fe161c865b 0B / 1.40kB 0.2s
#6 sha256:7cb374baf96870045ef10fb2275d30d893e2010d5fb12d2e8f949babcb3de6bf 965B / 965B 0.2s done
#6 sha256:1dc588c89da10830dde2a359d1b421e384caaae52458be045dcf6770ae7d624a 0B / 1.21kB 0.2s
#6 sha256:4c8c172c658661b7927fad4ab766c7e6c597d83400a3ed3f2e484c5940b4c56a 404B / 404B 0.2s done
#6 sha256:61d8f4c85a745813b78f7b3ea04d0268fd196753e0964ac6cd3f55fe161c865b 1.40kB / 1.40kB 0.3s done
#6 sha256:1dc588c89da10830dde2a359d1b421e384caaae52458be045dcf6770ae7d624a 1.21kB / 1.21kB 0.3s done
#6 sha256:c4f3d97811f679e18a790555496d98de98efbd4a61f8741c1aeedd86317c5f6c 20.54MB / 20.54MB 0.4s
#6 extracting sha256:04c3905a997c5ada93c8e4ad6c8d593e04c5ad4efa87a648a72f34138ea47117
#6 sha256:c4f3d97811f679e18a790555496d98de98efbd4a61f8741c1aeedd86317c5f6c 20.54MB / 20.54MB 0.5s done
#6 extracting sha256:04c3905a997c5ada93c8e4ad6c8d593e04c5ad4efa87a648a72f34138ea47117 done
#6 extracting sha256:7cb374baf96870045ef10fb2275d30d893e2010d5fb12d2e8f949babcb3de6bf done
#6 extracting sha256:4c8c172c658661b7927fad4ab766c7e6c597d83400a3ed3f2e484c5940b4c56a done
#6 extracting sha256:1dc588c89da10830dde2a359d1b421e384caaae52458be045dcf6770ae7d624a done
#6 extracting sha256:61d8f4c85a745813b78f7b3ea04d0268fd196753e0964ac6cd3f55fe161c865b done
#6 extracting sha256:c4f3d97811f679e18a790555496d98de98efbd4a61f8741c1aeedd86317c5f6c 0.1s
#6 extracting sha256:c4f3d97811f679e18a790555496d98de98efbd4a61f8741c1aeedd86317c5f6c 0.3s done
#6 DONE 1.2s

#7 [2/4] COPY nginx/default.conf /etc/nginx/conf.d/default.conf
#7 DONE 0.0s

#8 [3/4] COPY site/ /usr/share/nginx/html/
#8 DONE 0.0s

#9 [4/4] RUN chmod -R 755 /usr/share/nginx/html
#9 DONE 0.1s

#10 exporting to image
#10 exporting layers
#10 exporting layers 0.2s done
#10 writing image sha256:b6b42bdcf14961e90d7b108b79ee033fec2951c62258344d78e223effcc34306 done
#10 naming to docker.io/library/codyssey-dev-station:1.0 done
#10 DONE 0.2s
$ docker images codyssey-dev-station:1.0
REPOSITORY             TAG       IMAGE ID       CREATED        SIZE
codyssey-dev-station   1.0       b6b42bdcf149   1 second ago   63MB
$ docker run -d -p 127.0.0.1:8080:80 --name codyssey-verify-2019-web-a codyssey-dev-station:1.0
fd0cf3747c660c9b08a922736973f7dbb265118282ae67742276745a7ae69dc1
$ docker run -d -p 127.0.0.1:8081:80 --name codyssey-verify-2019-web-b codyssey-dev-station:1.0
6675c5a7c45b425879a2c251a2bdf50a6925c50c738d521c9baaafd6e84459cc
$ curl -fsSi http://127.0.0.1:8080/health
HTTP/1.1 200 OK
Server: nginx
Date: Mon, 23 Nov 2026 11:03:25 GMT
Content-Type: text/plain; charset=utf-8
Content-Length: 3
Connection: keep-alive

ok
$ curl -fsS -o /dev/null -w 웹\ 페이지\ HTTP\ %\{http_code\}\\n http://127.0.0.1:8080/
웹 페이지 HTTP 200
$ curl -fsSi http://127.0.0.1:8081/health
HTTP/1.1 200 OK
Server: nginx
Date: Mon, 23 Nov 2026 11:03:25 GMT
Content-Type: text/plain; charset=utf-8
Content-Length: 3
Connection: keep-alive

ok
$ curl -fsS -o /dev/null -w 웹\ 페이지\ HTTP\ %\{http_code\}\\n http://127.0.0.1:8081/
웹 페이지 HTTP 200
$ docker ps --filter name=codyssey-verify-2019
CONTAINER ID   IMAGE                      COMMAND                  CREATED                  STATUS                                     PORTS                    NAMES
6675c5a7c45b   codyssey-dev-station:1.0   "/docker-entrypoint.…"   Less than a second ago   Up Less than a second (health: starting)   127.0.0.1:8081->80/tcp   codyssey-verify-2019-web-b
fd0cf3747c66   codyssey-dev-station:1.0   "/docker-entrypoint.…"   Less than a second ago   Up Less than a second (health: starting)   127.0.0.1:8080->80/tcp   codyssey-verify-2019-web-a
$ docker logs codyssey-verify-2019-web-a
/docker-entrypoint.sh: /docker-entrypoint.d/ is not empty, will attempt to perform configuration
/docker-entrypoint.sh: Looking for shell scripts in /docker-entrypoint.d/
/docker-entrypoint.sh: Launching /docker-entrypoint.d/10-listen-on-ipv6-by-default.sh
10-listen-on-ipv6-by-default.sh: info: Getting the checksum of /etc/nginx/conf.d/default.conf
10-listen-on-ipv6-by-default.sh: info: /etc/nginx/conf.d/default.conf differs from the packaged version
/docker-entrypoint.sh: Sourcing /docker-entrypoint.d/15-local-resolvers.envsh
/docker-entrypoint.sh: Launching /docker-entrypoint.d/20-envsubst-on-templates.sh
/docker-entrypoint.sh: Launching /docker-entrypoint.d/30-tune-worker-processes.sh
/docker-entrypoint.sh: Configuration complete; ready for start up
2026/11/23 11:03:25 [notice] 1#1: using the "epoll" event method
2026/11/23 11:03:25 [notice] 1#1: nginx/1.31.9
2026/11/23 11:03:25 [notice] 1#1: built by gcc 15.2.0 (Alpine 15.2.0) 
2026/11/23 11:03:25 [notice] 1#1: OS: Linux 7.0.0-1017-azure
2026/11/23 11:03:25 [notice] 1#1: getrlimit(RLIMIT_NOFILE): 65536:65536
2026/11/23 11:03:25 [notice] 1#1: start worker processes
2026/11/23 11:03:25 [notice] 1#1: start worker process 29
2026/11/23 11:03:25 [notice] 1#1: start worker process 30
2026/11/23 11:03:25 [notice] 1#1: start worker process 31
2026/11/23 11:03:25 [notice] 1#1: start worker process 32
172.17.0.1 - - [23/Nov/2026:11:03:25 +0000] "GET / HTTP/1.1" 200 6613 "-" "curl/8.5.0" "-"
$ docker stats --no-stream codyssey-verify-2019-web-a codyssey-verify-2019-web-b
CONTAINER ID   NAME                         CPU %     MEM USAGE / LIMIT     MEM %     NET I/O           BLOCK I/O     PIDS
fd0cf3747c66   codyssey-verify-2019-web-a   0.00%     5.453MiB / 15.61GiB   0.03%     2.66kB / 8.62kB   0B / 12.3kB   5
6675c5a7c45b   codyssey-verify-2019-web-b   0.00%     4.734MiB / 15.61GiB   0.03%     2.69kB / 8.66kB   0B / 4.1kB    5
```

## 바인드 마운트의 호스트 파일 변경 전후

```text
$ cp bind-demo/index.html /tmp/tmp.jwedwLb8hJ/index.html
$ docker run -d -p 127.0.0.1:8082:80 --name codyssey-verify-2019-bind --mount type=bind\,source=/tmp/tmp.jwedwLb8hJ\,target=/usr/share/nginx/html\,readonly codyssey-dev-station:1.0
7f89335f4407b29a9c239c6a48f5e440e3d72c3b073492c0c80fbff8318706df
curl: (56) Recv failure: Connection reset by peer
$ curl -fsS http://127.0.0.1:8082/
<body><h1>bind mount: original</h1><p>호스트 파일이 컨테이너에 연결되었습니다.</p></body>
$ sed -i s/bind\ mount:\ original/bind\ mount:\ updated/ /tmp/tmp.jwedwLb8hJ/index.html
$ curl -fsS http://127.0.0.1:8082/
<body><h1>bind mount: updated</h1><p>호스트 파일이 컨테이너에 연결되었습니다.</p></body>
```

## 컨테이너 삭제 전후 볼륨 데이터

```text
$ docker volume create codyssey-verify-2019-data
codyssey-verify-2019-data
$ docker run -d --name codyssey-verify-2019-volume-a -v codyssey-verify-2019-data:/data ubuntu:24.04 sleep 300
76786c80751d8238ea282a0bf345a4681637eec1559213e04e77b2dce749e619
$ docker exec codyssey-verify-2019-volume-a sh -c echo\ persistent-data\ \>\ /data/proof.txt
$ docker exec codyssey-verify-2019-volume-a cat /data/proof.txt
persistent-data
$ docker rm -f codyssey-verify-2019-volume-a
codyssey-verify-2019-volume-a
$ docker run -d --name codyssey-verify-2019-volume-b -v codyssey-verify-2019-data:/data ubuntu:24.04 sleep 300
e6d9e028487a05b1769d665c92a4bfbff1c2e5b3ebfe99fabe9a82fe6eab7ef0
$ docker exec codyssey-verify-2019-volume-b cat /data/proof.txt
persistent-data
$ docker volume inspect codyssey-verify-2019-data --format \{\{.Name\}\}\ /\ \{\{.Driver\}\}
codyssey-verify-2019-data / local
```

## 중지와 중지된 컨테이너 조회

```text
$ docker stop codyssey-verify-2019-web-b
codyssey-verify-2019-web-b
$ docker ps -a --filter name=codyssey-verify-2019
CONTAINER ID   IMAGE                      COMMAND                  CREATED                  STATUS                              PORTS                    NAMES
e6d9e028487a   ubuntu:24.04               "sleep 300"              Less than a second ago   Up Less than a second                                        codyssey-verify-2019-volume-b
7f89335f4407   codyssey-dev-station:1.0   "/docker-entrypoint.…"   2 seconds ago            Up 1 second (health: starting)      127.0.0.1:8082->80/tcp   codyssey-verify-2019-bind
6675c5a7c45b   codyssey-dev-station:1.0   "/docker-entrypoint.…"   4 seconds ago            Exited (0) Less than a second ago                            codyssey-verify-2019-web-b
fd0cf3747c66   codyssey-dev-station:1.0   "/docker-entrypoint.…"   4 seconds ago            Up 4 seconds (health: starting)     127.0.0.1:8080->80/tcp   codyssey-verify-2019-web-a
9d0939cc7117   ubuntu:24.04               "bash"                   7 seconds ago            Exited (0) 7 seconds ago                                     codyssey-verify-2019-ubuntu

Docker 필수 검증 통과

남겨 둔 리소스: codyssey-verify-2019 / codyssey-verify-2019-data / /tmp/tmp.jwedwLb8hJ
```
