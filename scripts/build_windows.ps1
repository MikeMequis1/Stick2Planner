#requires -Version 5.1
<#
.SYNOPSIS
  Gera o build Windows x64 e o ZIP portátil do Stick2Planner.

.DESCRIPTION
  Executa `flutter build windows --release`, copia o bundle completo
  (executável, DLLs, dados e assets) e cria dist/windows/*.zip.
  Nenhuma biblioteca de runtime é removida.

.PREREQUISITES
  - Flutter 3.47+ no PATH.
  - Visual Studio com "Desktop development with C++" (MSVC, CMake, Windows SDK).
  - Modo de desenvolvedor do Windows habilitado (Flutter cria symlinks para plugins).

.EXAMPLE
  pwsh -File scripts/build_windows.ps1
#>
[CmdletBinding()]
param(
    [switch]$SkipPubGet
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
Push-Location $root
try {
    $developerMode = (Get-ItemProperty `
        -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock' `
        -Name AllowDevelopmentWithoutDevLicense `
        -ErrorAction SilentlyContinue).AllowDevelopmentWithoutDevLicense
    if ($developerMode -ne 1) {
        Write-Warning ('Developer Mode appears to be disabled. Flutter needs symlink ' +
            'support to build with plugins. Enable it in Settings > System > For developers ' +
            'or run this script from an elevated terminal.')
    }

    if (-not $SkipPubGet) {
        flutter pub get
    }

    flutter build windows --release

    $release = Join-Path $root 'build\windows\x64\runner\Release'
    $exe = Join-Path $release 'stick2planner.exe'
    if (-not (Test-Path $exe)) {
        throw "Windows release bundle not found at $release"
    }

    $versionLine = Get-Content (Join-Path $root 'pubspec.yaml') |
        Where-Object { $_ -match '^version:\s*(.+)$' } |
        Select-Object -First 1
    if (-not $versionLine) { throw 'Version not found in pubspec.yaml' }
    $version = ($versionLine -replace '^version:\s*', '') -replace '\+.*$', ''

    $dist = Join-Path $root 'dist\windows'
    New-Item -ItemType Directory -Force -Path $dist | Out-Null
    $stage = Join-Path $dist "Stick2Planner-$version-windows-x64"
    if (Test-Path $stage) { Remove-Item $stage -Recurse -Force }
    New-Item -ItemType Directory -Force -Path $stage | Out-Null
    Copy-Item -Path (Join-Path $release '*') -Destination $stage -Recurse -Force

    @"
Stick2Planner $version - portable Windows x64 build

Run stick2planner.exe. Keep the whole folder together: the data\ directory,
DLLs and Visual C++ runtime files are required.

User data is stored outside this folder, in the Windows application support
directory, and survives replacing this portable build.
"@ | Set-Content -Path (Join-Path $stage 'README.txt') -Encoding UTF8

    $zip = Join-Path $dist "Stick2Planner-$version-windows-x64.zip"
    if (Test-Path $zip) { Remove-Item $zip -Force }
    Compress-Archive -Path (Join-Path $stage '*') -DestinationPath $zip `
        -CompressionLevel Optimal
    Write-Host "Portable ZIP created: $zip"
}
finally {
    Pop-Location
}
