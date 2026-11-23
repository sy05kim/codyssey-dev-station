# Dev Station · Codyssey 개발 작업실 미션

터미널과 Git으로 작업 환경을 구성하고, NGINX 기반 정적 웹 서버를 Docker 이미지로 만들어 실행합니다. 포트 매핑으로 웹에 접속하고, 바인드 마운트의 파일 변경 반영과 Docker 볼륨의 데이터 영속성을 확인합니다.

[공개 제출 저장소](https://github.com/sy05kim/codyssey-dev-station)

## 수행 체크리스트

| 항목 | 확인 방법 | 결과 |
|---|---|---|
| 터미널 기본 조작 | `pwd`, `cd`, `ls -la`, `mkdir`, `touch`, `cp`, `mv`, `cat`, `rm` | [실행 로그](docs/cli-practice-log.md) |
| 파일·디렉터리 권한 | `chmod`, `ls -ld`로 변경 전후 확인 | [파일 600 → 644, 디렉터리 700 → 755](docs/cli-practice-log.md#경로와-권한-해석) |
| Docker 엔진과 운영 | `docker --version`, `info`, `pull`, `images`, `ps -a`, `logs`, `stats`, `stop` | [Docker 실행 로그](docs/docker-practice-log.md) |
| 기본 컨테이너 | `hello-world` 실행, Ubuntu에서 `exec`와 `attach` 비교 | [Docker 실행 로그](docs/docker-practice-log.md) |
| 커스텀 Dockerfile | `docker build`와 `docker run` | [Dockerfile](Dockerfile) · [웹 소스](site/) · [빌드·실행 로그](docs/docker-practice-log.md) |
| 포트 매핑 | 동일 이미지로 8080 및 8081에서 HTTP 응답 확인 | [HTTP 응답](docs/docker-practice-log.md) · [주소창 포함 브라우저 캡처](docs/browser-8080.png) |
| 바인드 마운트 | 호스트의 HTML을 수정한 뒤 `curl` 재요청 | [original → updated](docs/docker-practice-log.md) |
| Docker 볼륨 | 첫 컨테이너 삭제 후 새 컨테이너에서 같은 볼륨 읽기 | [persistent-data 유지](docs/docker-practice-log.md) |
| Git과 GitHub | `main`과 원격 저장소 확인 | [Git 설정 및 원격 연결 기록](docs/git-vscode-evidence.md) |
| VS Code 연동 | Accounts에서 GitHub 로그인, Source Control에서 저장소 확인 | [개인 PC 증거 첨부 대기](docs/git-vscode-evidence.md#vs-code-연동-캡처) |

## 실행 환경

Docker 실행 로그와 브라우저 캡처는 GitHub Actions의 Ubuntu 환경에서 수집했습니다. Windows Docker Desktop 설치 기록과 엔진 오류는 [Windows 진단](docs/docker-engine-diagnosis.md)에서 확인할 수 있습니다.

| 작업 | 환경 |
|---|---|
| 터미널·권한 | Debian 13, Bash 터미널에서 POSIX 셸 실행 |
| Docker·브라우저 | Ubuntu 24.04.5 LTS, Bash, Chrome, Docker CLI·엔진 28.0.4, Git 2.56.1 |
| 기존 Windows 작업 | Windows 11, PowerShell 7.6.9 / Git Bash, Git 2.55.0.windows.5, Docker Desktop 4.99.0 |

Docker CLI·서버·Git 버전의 실제 출력은 [Docker 실행 로그](docs/docker-practice-log.md) 상단에 있습니다. [GitHub Actions 원본 실행](https://github.com/sy05kim/codyssey-dev-station/actions/runs/45161608202)에서도 단계별 결과를 볼 수 있습니다.

## 재현 방법

Docker 엔진이 실행 중인 환경에서 저장소를 받은 뒤 Bash로 실습합니다. Windows에서는 Docker Desktop의 WSL 통합이 켜진 WSL 터미널에서 같은 명령을 실행할 수 있습니다.

```bash
git clone https://github.com/sy05kim/codyssey-dev-station.git
cd codyssey-dev-station
sh scripts/cli-practice.sh
bash scripts/verify.sh
```

검증 스크립트는 실행 명령과 출력 결과를 순서대로 표시하고 이번 실행에서 만든 실습 컨테이너와 볼륨을 정리합니다. 8080, 8081, 8082 중 사용 중인 포트가 있다면 `PORT_A=9080 PORT_B=9081 PORT_BIND=9082 bash scripts/verify.sh`처럼 바꿔 실행합니다.

웹 화면을 브라우저에서 직접 확인하려면 다음 명령을 실행한 뒤 `http://127.0.0.1:8080/`에 접속합니다.

```bash
docker build -t codyssey-dev-station:1.0 .
docker run -d -p 127.0.0.1:8080:80 --name codyssey-web codyssey-dev-station:1.0
curl -i http://127.0.0.1:8080/health
docker logs codyssey-web
docker stop codyssey-web
docker rm codyssey-web
```

## 구현과 검증 원리

- **커스텀 이미지**는 `nginx:alpine`에 [HTML·CSS·JavaScript](site/)와 [NGINX 설정](nginx/default.conf)을 복사합니다. `/health`로 서버 응답을 점검하고, 이미지 레이블로 용도를 기록합니다.
- **포트 매핑**은 호스트의 8080·8081 각각을 서로 다른 컨테이너의 80번 포트에 연결합니다. 두 컨테이너는 같은 이미지에서 실행합니다.
- **Ubuntu 실행**에서 `exec`는 새 셸을 실행합니다. 이 셸 종료 뒤에는 컨테이너가 계속 실행됩니다. `attach`로 처음 실행한 Bash 프로세스에 연결해 `exit`를 보내면 컨테이너도 종료됩니다.
- **바인드 마운트**는 복사한 호스트 데모 폴더를 NGINX 문서 루트에 읽기 전용으로 연결합니다. 호스트가 HTML을 수정하면 이미지 재빌드 없이 응답이 바뀝니다.
- **명명된 볼륨**은 컨테이너에서 분리해 데이터를 저장합니다. 첫 컨테이너가 볼륨에 파일을 쓰고, 삭제 후에 같은 볼륨을 연결한 새 컨테이너가 파일을 읽습니다.
- **Git**은 로컬 변경 이력을 관리하고, **GitHub**는 원격 저장소를 통해 이력을 공유합니다.

## 문제 해결 기록

| 문제 | 원인 가설 | 확인 | 해결 또는 대안 |
|---|---|---|---|
| Windows에서 `docker` 인식 실패 | Docker Desktop 미설치 또는 PATH 미반영 | `Get-Command docker`와 표준 설치 경로에서 실행 파일을 찾지 못함 | `winget`으로 Docker Desktop 4.99.0 설치. 새 PowerShell에서 다시 확인 |
| Windows에서 Docker API 500 응답 | WSL2 백엔드에 필요한 가상화 기능이 비활성화됨 | 백엔드 로그에서 `Virtual Machine Platform not enabled` 확인 | [Windows 복구 절차](docs/docker-engine-diagnosis.md). 제출용 Docker 실습은 Linux에서 실행 |
| 첫 CI 실행에서 포트 8082가 연결을 재설정 | Docker가 포트를 열었지만 NGINX가 아직 요청을 처리할 준비가 되지 않음 | 실행 직후 `curl`이 오류 56으로 종료. 같은 실행에서 8080·8081은 HTTP 200 응답 | 준비 확인 요청이 연결 재설정을 포함한 일시적 오류를 재시도하도록 변경. [첫 실행 로그](https://github.com/sy05kim/codyssey-dev-station/actions/runs/45159981952) |

## 선택 과제 · Docker Compose

```bash
HOST_PORT=9080 docker compose up -d --build
docker compose ps
docker compose logs
docker compose down
```

`HOST_PORT`는 호스트 포트를 고르는 실행 설정으로, [Compose 구성](compose.yaml)과 [.env 예시](.env.example)에 정의되어 있습니다.
