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

function Format-Seconds([double]$value) {
    return $value.ToString('0.######', [System.Globalization.CultureInfo]::InvariantCulture)
}

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
    $arguments += @('-i', $source)
    if ($null -ne $asset.start) {
        $duration = [double]$asset.end - [double]$asset.start
        $arguments += @('-ss', (Format-Seconds([double]$asset.start)), '-t', (Format-Seconds($duration)))
    }
    $filters = @()
    if ($null -ne $asset.fade_out_s) {
        $fadeDuration = [double]($asset.fade_out_s)
        $fadeStart = [Math]::Max(0.0, ([double]$duration) - $fadeDuration)
        $sourceFadeStart = ([double]$asset.start) + $fadeStart
        $filters += "afade=t=out:st=$(Format-Seconds($sourceFadeStart)):d=$(Format-Seconds($fadeDuration))"
    }
    if ($null -ne $asset.gain_db) {
        $filters += "volume=$($asset.gain_db)dB"
    }
    if ($filters.Count -gt 0) {
        $arguments += @('-af', ($filters -join ','))
    }
    $arguments += @('-c:a', 'libvorbis', '-q:a', '5', $output)
    & $ffmpeg @arguments
    if ($LASTEXITCODE -ne 0) {
        throw "Conversion échouée pour ${name}."
    }
    Write-Host "Préparé : $name -> $($asset.output)"
}
