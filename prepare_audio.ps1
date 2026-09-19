param(
    [switch]$KeepGoing
)

$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot
$manifestPath = Join-Path $root 'sounds\audio_manifest.json'
$sourceDir = Join-Path $root 'sounds\sources'
$outputDir = Join-Path $root 'godot\audio\generated'
$ffmpeg = (Get-Command ffmpeg -ErrorAction Stop).Source
$manifest = Get-Content -Raw -LiteralPath $manifestPath | ConvertFrom-Json

New-Item -ItemType Directory -Force -Path $outputDir | Out-Null

foreach ($property in $manifest.assets.PSObject.Properties) {
    $name = $property.Name
    $asset = $property.Value
    $source = Join-Path $sourceDir $asset.source
    $output = Join-Path $outputDir $asset.output
    if (-not (Test-Path -LiteralPath $source)) {
        throw "Source audio manquante pour ${name}: $source"
    }
    $arguments = @('-y')
    if ($null -ne $asset.start) {
        $arguments += @('-ss', [string]$asset.start, '-to', [string]$asset.end)
    }
    $arguments += @('-i', $source)
    if ($null -ne $asset.start) {
        $duration = [double]$asset.end - [double]$asset.start
        $fadeOutStart = [Math]::Max(0, $duration - 0.05)
        $arguments += @('-af', "afade=t=in:st=0:d=0.015,afade=t=out:st=${fadeOutStart}:d=0.05")
    }
    $arguments += @('-c:a', 'libvorbis', '-q:a', '5', $output)
    & $ffmpeg @arguments
    if ($LASTEXITCODE -ne 0) {
        throw "Conversion échouée pour ${name}."
    }
    Write-Host "Préparé : $name -> $($asset.output)"
}
