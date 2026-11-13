#requires -Version 5.1
<#
.SYNOPSIS
  (Optional) Empacota o build Windows como MSIX.

.DESCRIPTION
  Usa o bundle já gerado em build/windows/x64/runner/Release, substitui os
  placeholders do AppxManifest.xml e chama o MakeAppx do Windows SDK.
  A assinatura é opcional; sem certificado o MSIX é gerado sem assinatura.

.PREREQUISITES
  - Windows 10 SDK (MakeAppx.exe) e, para assinar, signtool.exe.
  - Publisher do manifesto igual ao Subject do certificado usado na assinatura.
  - Build Windows release disponível.

.EXAMPLE
  pwsh -File scripts/package_windows_msix.ps1 -Publisher "CN=Stick2Planner"

.EXAMPLE
  pwsh -File scripts/package_windows_msix.ps1 `
    -Publisher "CN=Stick2Planner" `
    -CertificatePath ".\certs\stick2planner.pfx" `
    -CertificatePassword "senha"
#>
[CmdletBinding()]
param(
    [string]$Publisher = 'CN=Stick2Planner',
    [string]$CertificatePath,
    [string]$CertificatePassword,
    [string]$OutputPath,
    [switch]$SkipBuild
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
Push-Location $root
try {
    if (-not $SkipBuild) {
        flutter build windows --release
    }

    $release = Join-Path $root 'build\windows\x64\runner\Release'
    if (-not (Test-Path (Join-Path $release 'stick2planner.exe'))) {
        throw "Windows release bundle not found at $release. Run flutter build windows --release first."
    }

    $versionLine = Get-Content (Join-Path $root 'pubspec.yaml') |
        Where-Object { $_ -match '^version:\s*(.+)$' } |
        Select-Object -First 1
    if (-not $versionLine) { throw 'Version not found in pubspec.yaml' }
    $rawVersion = ($versionLine -replace '^version:\s*', '').Trim()
    $baseVersion, $buildNumber = $rawVersion.Split('+', 2)
    if (-not $buildNumber) { $buildNumber = '0' }
    $parts = $baseVersion.Split('.')
    while ($parts.Count -lt 3) { $parts += '0' }
    $msixVersion = "$($parts[0]).$($parts[1]).$($parts[2]).$buildNumber"

    $sdkBin = Join-Path ${env:ProgramFiles(x86)} 'Windows Kits\10\bin'
    $makeAppx = Get-ChildItem -Path $sdkBin -Filter makeappx.exe -Recurse -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -match '\\x64\\makeappx\.exe$' } |
        Sort-Object FullName -Descending |
        Select-Object -First 1
    if (-not $makeAppx) {
        throw "MakeAppx.exe not found under $sdkBin. Install the Windows 10/11 SDK."
    }

    $dist = Join-Path $root 'dist\windows\msix'
    New-Item -ItemType Directory -Force -Path $dist | Out-Null
    $stage = Join-Path $dist 'stage'
    if (Test-Path $stage) { Remove-Item $stage -Recurse -Force }
    New-Item -ItemType Directory -Force -Path $stage | Out-Null
    Copy-Item -Path (Join-Path $release '*') -Destination $stage -Recurse -Force

    $manifest = Get-Content (Join-Path $root 'packaging\windows\msix\AppxManifest.xml') -Raw
    $manifest = $manifest.Replace('__PUBLISHER__', $Publisher).Replace('__VERSION__', $msixVersion)
    Set-Content -Path (Join-Path $stage 'AppxManifest.xml') -Value $manifest -Encoding UTF8
    Copy-Item -Path (Join-Path $root 'packaging\windows\msix\Assets') `
        -Destination (Join-Path $stage 'Assets') -Recurse -Force

    if (-not $OutputPath) {
        $OutputPath = Join-Path $dist "Stick2Planner-$baseVersion-windows-x64.msix"
    }
    if (Test-Path $OutputPath) { Remove-Item $OutputPath -Force }

    & $makeAppx.FullName pack /d $stage /p $OutputPath /o
    if ($LASTEXITCODE -ne 0) { throw "MakeAppx failed with exit code $LASTEXITCODE" }

    if ($CertificatePath) {
        $signTool = Get-ChildItem -Path $sdkBin -Filter signtool.exe -Recurse -ErrorAction SilentlyContinue |
            Where-Object { $_.FullName -match '\\x64\\signtool\.exe$' } |
            Sort-Object FullName -Descending |
            Select-Object -First 1
        if (-not $signTool) { throw 'signtool.exe not found in the Windows SDK.' }
        $signArgs = @('sign', '/fd', 'SHA256', '/f', (Resolve-Path $CertificatePath))
        if ($CertificatePassword) {
            $signArgs += @('/p', $CertificatePassword)
        }
        $signArgs += $OutputPath
        & $signTool.FullName @signArgs
        if ($LASTEXITCODE -ne 0) { throw "signtool failed with exit code $LASTEXITCODE" }
        Write-Host "Signed MSIX created: $OutputPath"
    }
    else {
        Write-Host "Unsigned MSIX created: $OutputPath"
        Write-Host 'Installation requires a trusted signing certificate or Developer Mode sideloading.'
    }
}
finally {
    Pop-Location
}
