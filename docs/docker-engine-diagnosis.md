# Docker 엔진 진단

## 현재 상태

- Docker Desktop 4.99.0 설치 완료
- Docker CLI 설치 경로 확인 완료
- WSL2 기반 Linux 엔진은 시작되지 않음
- 프로젝트 소스와 자동 검증 스크립트 준비 완료

## 실제 오류

```text
request returned 500 Internal Server Error for API route and version
http://%2F%2F.%2Fpipe%2FdockerDesktopLinuxEngine/v1.56/info
```

Docker Desktop 백엔드 로그에서 확인한 핵심 원인:

```text
engine linux/wsl failed to start: checking preconditions:
Virtual Machine Platform not enabled
No virtualization available
```

## 완료 절차

관리자 PowerShell에서 다음 Windows 기능을 활성화합니다.

```powershell
Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -All -NoRestart
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -All -NoRestart
```

그다음 Windows를 재부팅하고 Docker Desktop을 실행합니다.

```powershell
docker info
./scripts/verify.ps1 -KeepResources
```

가상화가 계속 감지되지 않으면 작업 관리자 `성능 > CPU > 가상화`가 `사용`인지 확인하고, 꺼져 있다면 BIOS/UEFI에서 Intel VT-x 또는 AMD-V를 활성화해야 합니다. BIOS 설정은 기기 제조사 안내에 따라 사용자가 직접 변경해야 합니다.

## 검증 완료 기준

1. `docker info`가 서버 버전과 Linux 운영체제를 반환합니다.
2. `codyssey-dev-station:1.0` 이미지 빌드가 성공합니다.
3. `localhost:8080/health`, `localhost:8081/health`가 모두 `ok`를 반환합니다.
4. 바인드 마운트 응답이 `original`에서 `updated`로 바뀝니다.
5. 첫 컨테이너를 삭제한 뒤 두 번째 컨테이너에서도 `persistent-data`가 출력됩니다.
