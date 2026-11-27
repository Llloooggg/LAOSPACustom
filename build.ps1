# Builds L_aospa_custom into L_aospa_custom.zip next to this folder.
# Usage: powershell -ExecutionPolicy Bypass -File .\build.ps1

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

$root = $PSScriptRoot
$out  = Join-Path (Split-Path $root -Parent) 'L_aospa_custom.zip'

$files = Get-ChildItem -Recurse -File $root |
    Where-Object { $_.Name -ne 'build.ps1' -and $_.Extension -ne '.zip' -and $_.FullName -notmatch '\\\.git\\' }

if (Test-Path $out) { Remove-Item $out -Force }
$fs = [IO.File]::Open($out, [IO.FileMode]::Create)
$za = New-Object IO.Compression.ZipArchive($fs, [IO.Compression.ZipArchiveMode]::Create)
foreach ($f in $files) {
    $rel = $f.FullName.Substring($root.Length + 1).Replace('\', '/')
    $e = $za.CreateEntry($rel)
    $s = $e.Open()
    $b = [IO.File]::ReadAllBytes($f.FullName)
    $s.Write($b, 0, $b.Length)
    $s.Close()
}
$za.Dispose()
$fs.Close()

"built: $out"
Get-ChildItem -Recurse -File $root |
    Where-Object { $_.Name -ne 'build.ps1' -and $_.Extension -ne '.zip' } |
    ForEach-Object { "  " + $_.FullName.Substring($root.Length + 1).Replace('\', '/') + "  " + $_.Length }
