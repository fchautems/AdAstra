param([switch]$Regenerate,[switch]$Test,[switch]$Editor,[switch]$Screenshots)
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath $PSScriptRoot
$env:APPDATA = Join-Path $PSScriptRoot 'tools\runtime\roaming'
$env:LOCALAPPDATA = Join-Path $PSScriptRoot 'tools\runtime\local'
New-Item -ItemType Directory -Force $env:APPDATA,$env:LOCALAPPDATA | Out-Null
$godot = Join-Path $PSScriptRoot 'tools\godot\Godot_v4.5.2-stable_win64_console.exe'
$blender = Join-Path $PSScriptRoot 'tools\blender\blender-4.5.7-windows-x64\blender.exe'
if (-not (Test-Path -LiteralPath $godot)) { throw 'Godot portable absent dans tools\godot.' }
if ($Regenerate) {
    if (-not (Test-Path -LiteralPath $blender)) { throw 'Blender portable absent dans tools\blender.' }
    & $blender --background --factory-startup --python-exit-code 1 --python (Join-Path $PSScriptRoot 'generate.py')
    if ($LASTEXITCODE -ne 0) { throw 'Generation Blender echouee.' }
}
& $godot --headless --path (Join-Path $PSScriptRoot 'godot') --editor --import
if ($LASTEXITCODE -ne 0) { throw 'Import Godot echoue.' }
if ($Test) {
    & $godot --path (Join-Path $PSScriptRoot 'godot') --disable-vsync --fixed-fps 120 -- --test
} elseif ($Screenshots) {
    & $godot --path (Join-Path $PSScriptRoot 'godot') -- --screenshots
} elseif ($Editor) {
    & $godot --path (Join-Path $PSScriptRoot 'godot') --editor
} else {
    & $godot --path (Join-Path $PSScriptRoot 'godot')
}
if ($LASTEXITCODE -ne 0) { throw 'Godot a signale une erreur. Voir la sortie ci-dessus.' }
