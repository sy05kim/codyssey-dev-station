# Dev Station - Codyssey 개발 작업실 미션

터미널, Docker, Git을 이용해 재현 가능한 정적 웹 서버 개발 환경을 구성한 프로젝트입니다. `nginx:alpine`을 기반으로 커스텀 이미지를 만들고, 포트 매핑·바인드 마운트·명명된 볼륨의 동작을 한 번에 검증할 수 있도록 소스와 자동화 스크립트를 함께 제공합니다.

> 이 저장소의 예시 출력은 실제 실행 결과와 실행 전 예상 결과를 섞지 않습니다. 현재 PC에서는 Docker Desktop 설치까지 완료했지만 Windows의 `VirtualMachinePlatform` 기능이 꺼져 있어 Docker 엔진 검증은 재부팅 후 실행해야 합니다. 자세한 진단은 [Docker 엔진 진단](docs/docker-engine-diagnosis.md)에 기록했습니다.

공개 제출 저장소: <https://github.com/sy05kim/codyssey-dev-station>

## 1. 프로젝트 개요

- 커스텀 NGINX 이미지로 반응형 정적 웹 페이지 제공
- `/health` 엔드포인트와 Docker `HEALTHCHECK` 제공
- 동일 이미지의 `8080:80`, `8081:80` 이중 포트 매핑 검증
- 호스트 파일 변경이 즉시 반영되는 바인드 마운트 검증
- 컨테이너 교체 후에도 데이터가 남는 Docker 볼륨 검증
- `HOST_PORT` 환경 변수로 포트를 바꾸는 Docker Compose 구성
- 터미널 파일 조작·권한 변경 실습과 실제 출력 기록

## 2. 수행 상태

| 항목 | 상태 | 증거/재현 위치 |
|---|---:|---|
| 터미널 기본 조작 | 완료 | [실제 CLI 로그](docs/cli-practice-log.md) |
| 파일·디렉터리 권한 644/755 | 완료 | [실제 CLI 로그](docs/cli-practice-log.md) |
| Docker Desktop 설치 | 완료 | 4.99.0 설치 확인 |
| 커스텀 Dockerfile/웹 소스 | 완료 | `Dockerfile`, `nginx/`, `site/` |
| 포트·바인드·볼륨 자동 검증 | 준비 완료 | `scripts/verify.ps1` |
| Docker 엔진 실증 로그 | 재부팅 후 실행 필요 | [원인과 완료 절차](docs/docker-engine-diagnosis.md) |
| Git 저장소/기본 브랜치 | 완료 | 로컬 저장소 `main` |
| GitHub 원격 저장소 | 완료 | [sy05kim/codyssey-dev-station](https://github.com/sy05kim/codyssey-dev-station) |

## 3. 실행 환경

| 구분 | 값 |
|---|---|
| OS | Microsoft Windows NT 10.0.26200.0, x64 |
| Shell | PowerShell 7.6.9 / Git Bash |
| Git | 2.55.0.windows.5 |
| Docker Desktop | 4.99.0 |
| Docker base image | `nginx:alpine` |
| 컨테이너 포트 | `80/tcp` |

Git 사용자 이름과 이메일은 로컬에 설정되어 있음을 확인했지만 개인정보 보호를 위해 문서에 값은 싣지 않았습니다.

## 4. 프로젝트 구조

```text
.
├── Dockerfile                 # NGINX 커스텀 이미지
├── compose.yaml               # 선택 과제: Compose + HOST_PORT
├── .env.example               # Compose 환경 변수 예시
├── nginx/
│   └── default.conf           # 정적 파일 및 /health 설정
├── site/
│   ├── index.html             # 웹 페이지
│   ├── styles.css             # 반응형 스타일
│   └── script.js              # 런타임 시계
├── bind-demo/
│   └── index.html             # 바인드 마운트 전/후 비교용
├── practice/
│   └── seed.txt               # CLI 복사·이름 변경용 원본
├── scripts/
│   ├── cli-practice.sh        # 터미널/권한 실습 재현
│   └── verify.ps1             # Docker 전체 검증 자동화
└── docs/
    ├── cli-practice-log.md
    └── docker-engine-diagnosis.md
```

## 5. 수행 체크리스트

- [x] 현재 위치 확인과 숨김 파일 포함 목록 조회
- [x] 디렉터리 생성, 빈 파일 생성, 복사, 이동/이름 변경, 삭제
- [x] 파일 내용 확인
- [x] 파일 `644`, 디렉터리 `755` 권한 변경과 전/후 확인
- [x] Git 사용자 설정 존재 및 기본 브랜치 확인
- [x] Docker Desktop 설치 및 CLI 위치 확인
- [x] Dockerfile 직접 작성
- [x] 정적 웹 서버와 `/health` 구성
- [x] Compose 및 포트 환경 변수 구성
- [ ] Docker 엔진 시작 확인 (`VirtualMachinePlatform` 활성화와 재부팅 필요)
- [ ] 이미지 빌드와 `docker images` 결과 기록
- [ ] `hello-world`, 컨테이너 진입 및 `docker ps -a` 기록
- [ ] 8080/8081 포트 응답, `docker logs`, `docker stats` 기록
- [ ] 바인드 마운트 전/후 응답 비교
- [ ] 볼륨 연결 및 컨테이너 삭제 전/후 데이터 비교
- [x] GitHub 공개 저장소 생성 및 `main` 브랜치 push
- [ ] VSCode 연결 화면 확보

미완료 Docker 항목은 환경 활성화 후 다음 한 명령으로 순서대로 검증됩니다.

```powershell
./scripts/verify.ps1 -KeepResources
```

## 6. Docker 빌드 및 기본 실행

### 설치 점검

```powershell
docker --version
docker info
docker images
docker ps -a
```

### 커스텀 이미지 빌드

```powershell
docker build -t codyssey-dev-station:1.0 .
docker images codyssey-dev-station:1.0
```

이 Dockerfile의 커스텀 포인트는 다음과 같습니다.

1. `nginx:alpine`을 기존 베이스 이미지로 선택했습니다.
2. `default.conf`로 `/health`, 정적 파일 라우팅, 캐시 헤더를 추가했습니다.
3. 자체 HTML/CSS/JS 콘텐츠를 이미지에 복사했습니다.
4. OCI 메타데이터, `APP_ENV`, `HEALTHCHECK`를 추가했습니다.

### 동일 이미지를 두 포트에서 실행

```powershell
docker run -d -p 8080:80 --name codyssey-web-8080 codyssey-dev-station:1.0
docker run -d -p 8081:80 --name codyssey-web-8081 codyssey-dev-station:1.0
curl.exe http://localhost:8080/health
curl.exe http://localhost:8081/health
docker ps --filter "name=codyssey-web"
docker logs codyssey-web-8080
docker stats --no-stream codyssey-web-8080 codyssey-web-8081
```

포트 매핑이 필요한 이유는 컨테이너 내부의 `80/tcp`가 호스트에서 자동으로 노출되지 않기 때문입니다. `8080:80`은 `호스트 포트:컨테이너 포트`이며, 같은 이미지를 격리된 컨테이너로 여러 번 실행할 수 있습니다.

브라우저 확인 주소:

- `http://localhost:8080`
- `http://localhost:8081`
- `http://localhost:8080/health`

## 7. 바인드 마운트 검증

호스트의 `bind-demo` 디렉터리를 NGINX 문서 루트에 읽기 전용으로 연결합니다.

```powershell
$bindPath = (Resolve-Path ./bind-demo).Path
docker run -d -p 8082:80 --name codyssey-bind-demo `
  -v "${bindPath}:/usr/share/nginx/html:ro" `
  codyssey-dev-station:1.0
curl.exe http://localhost:8082
```

호스트의 `bind-demo/index.html`에서 `original`을 `updated`로 바꾼 뒤 다시 요청하면 이미지 재빌드 없이 결과가 변경됩니다. 검증 스크립트는 변경 전후를 요청한 다음 원본 파일을 복구합니다.

## 8. Docker 볼륨 영속성 검증

```powershell
docker volume create codyssey-mission-data
docker run -d --name codyssey-volume-a `
  -v codyssey-mission-data:/data `
  codyssey-dev-station:1.0 `
  sh -c "printf 'persistent-data\n' > /data/proof.txt && sleep 300"
docker exec codyssey-volume-a cat /data/proof.txt
docker rm -f codyssey-volume-a

docker run -d --name codyssey-volume-b `
  -v codyssey-mission-data:/data `
  codyssey-dev-station:1.0 sh -c "sleep 300"
docker exec codyssey-volume-b cat /data/proof.txt
```

두 번째 컨테이너에서도 `persistent-data`가 출력되면 컨테이너와 데이터 수명이 분리되어 있음을 증명합니다.

## 9. Docker Compose 선택 과제

```powershell
Copy-Item .env.example .env
docker compose up -d --build
docker compose ps
docker compose logs
docker compose down
```

`.env`의 `HOST_PORT=8080` 값을 바꾸면 Compose 파일을 수정하지 않고 호스트 공개 포트를 바꿀 수 있습니다. 이는 실행 설정과 이미지/소스 코드를 분리합니다.

## 10. Git과 GitHub

현재 로컬 Git 설정은 사용자 정보가 구성되어 있고 기본 브랜치는 `main`입니다.

```powershell
git config --list
git status
git log --oneline --decorate -5
```

Git은 로컬 버전 관리 도구이고, GitHub는 원격 저장소·협업·리뷰를 제공하는 서비스입니다. 제출 전 GitHub에서 빈 저장소를 만든 뒤 다음 명령으로 연결합니다.

```powershell
git remote add origin https://github.com/<account>/codyssey-dev-station.git
git push -u origin main
git remote -v
```

VSCode에서는 Accounts 메뉴로 GitHub에 로그인한 뒤 Source Control 화면에서 연결된 저장소와 동기화 상태를 확인합니다. 토큰·비밀번호·인증 코드가 캡처나 커밋에 포함되지 않도록 주의합니다.

## 11. 문제 해결 기록

### 사례 1 - `docker` 명령을 찾을 수 없음

- 문제: `docker --version`이 PowerShell에서 인식되지 않았습니다.
- 원인 가설: Docker Desktop이 설치되지 않았거나 PATH가 현재 셸에 반영되지 않았습니다.
- 확인: `Get-Command docker`와 표준 설치 경로를 확인했을 때 실행 파일이 없었습니다.
- 해결: `winget`으로 Docker Desktop 4.99.0을 설치했습니다. 새 셸 전까지는 `C:\Program Files\Docker\Docker\resources\bin\docker.exe` 절대 경로로도 실행할 수 있습니다.

### 사례 2 - Docker API가 500으로 응답

- 문제: Docker CLI가 `dockerDesktopLinuxEngine`의 `/info` 요청에 500을 반환했습니다.
- 원인 가설: WSL2 백엔드가 시작되기 위한 Windows 가상화 구성요소가 비활성화되어 있습니다.
- 확인: Docker 백엔드 로그에 `Virtual Machine Platform not enabled`와 `No virtualization available`이 기록됐습니다.
- 해결/대안: 관리자 권한으로 `VirtualMachinePlatform`과 WSL 기능을 활성화하고 Windows를 재부팅한 뒤 `scripts/verify.ps1`을 실행합니다. 현재 세션에서는 관리자 승인과 재부팅이 필요한 단계라 실증 로그를 만들지 않았습니다.

## 12. 보안과 개인정보

- `.env`, 로그, 임시 폴더는 `.gitignore`에서 제외합니다.
- Git 이메일·토큰·비밀번호·인증 코드는 README나 캡처에 넣지 않습니다.
- 바인드 마운트는 데모 콘텐츠에만 적용하고 `:ro`로 제한합니다.
- Docker 검증 출력 공유 전 사용자 경로와 계정 정보를 다시 확인합니다.
