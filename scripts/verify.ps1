[CmdletBinding()]
param(
    [switch]$KeepResources
)

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$image = 'codyssey-dev-station:1.0'
$containerA = 'codyssey-web-8080'
$containerB = 'codyssey-web-8081'
$bindContainer = 'codyssey-bind-demo'
$volumeA = 'codyssey-volume-a'
$volumeB = 'codyssey-volume-b'
$volume = 'codyssey-mission-data'

function Write-Step([string]$Message) {
    Write-Host "`n==> $Message" -ForegroundColor Cyan
}
function Remove-ContainerIfPresent([string]$Name) {
    $existing = docker ps -aq --filter "name=^/${Name}$"
    if ($existing) { docker rm -f $Name | Out-Null }
}

Push-Location $projectRoot
try {
    Write-Step 'Environment'
    docker --version
    docker info --format 'Server {{.ServerVersion}} / {{.OperatingSystem}}'
    git --version

    Write-Step 'Build custom image'
    docker build -t $image .

    Write-Step 'Run standard containers'
    docker run --rm hello-world
    docker run --rm ubuntu:24.04 sh -c 'printf "inside ubuntu: "; pwd; printf "sample file\n" > /tmp/mission.txt; ls -l /tmp/mission.txt; cat /tmp/mission.txt'

    Write-Step 'Run the same image on host ports 8080 and 8081'
    Remove-ContainerIfPresent $containerA
    Remove-ContainerIfPresent $containerB
    docker run -d -p 8080:80 --name $containerA $image
    docker run -d -p 8081:80 --name $containerB $image
    Start-Sleep -Seconds 3
    "8080 => $((Invoke-WebRequest -UseBasicParsing http://localhost:8080/health).Content.Trim())"
    "8081 => $((Invoke-WebRequest -UseBasicParsing http://localhost:8081/health).Content.Trim())"
    docker ps --filter "name=codyssey-web" --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'
    docker logs $containerA
    docker stats --no-stream $containerA $containerB

    Write-Step 'Bind mount reflects a host-side change'
    Remove-ContainerIfPresent $bindContainer
    $bindPath = (Resolve-Path '.\bind-demo').Path
    docker run -d -p 8082:80 --name $bindContainer -v "${bindPath}:/usr/share/nginx/html:ro" $image
    Start-Sleep -Seconds 2
    $before = (Invoke-WebRequest -UseBasicParsing http://localhost:8082/).Content
    "before => $([regex]::Match($before, '<h1>(.*?)</h1>').Groups[1].Value)"
    $demoFile = Join-Path $bindPath 'index.html'
    $original = Get-Content -Raw $demoFile
    try {
        $updated = $original.Replace('bind mount: original', 'bind mount: updated')
        Set-Content -Path $demoFile -Value $updated -Encoding utf8
        $after = (Invoke-WebRequest -UseBasicParsing http://localhost:8082/).Content
        "after  => $([regex]::Match($after, '<h1>(.*?)</h1>').Groups[1].Value)"
    }
    finally {
        Set-Content -Path $demoFile -Value $original -Encoding utf8 -NoNewline
    }

    Write-Step 'Named volume survives container replacement'
    Remove-ContainerIfPresent $volumeA
    Remove-ContainerIfPresent $volumeB
    docker volume create $volume
    docker run -d --name $volumeA -v "${volume}:/data" $image sh -c "printf 'persistent-data`n' > /data/proof.txt && sleep 300"
    docker exec $volumeA cat /data/proof.txt
    docker rm -f $volumeA
    docker run -d --name $volumeB -v "${volume}:/data" $image sh -c 'sleep 300'
    docker exec $volumeB cat /data/proof.txt

    Write-Step 'Final inventory'
    docker images $image
    docker ps -a --filter 'name=codyssey-' --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'
    docker volume inspect $volume --format '{{.Name}} / {{.Driver}}'
}
finally {
    Pop-Location
    if (-not $KeepResources) {
        foreach ($name in @($containerA, $containerB, $bindContainer, $volumeA, $volumeB)) {
            Remove-ContainerIfPresent $name
        }
    }
}
