# Clean old build files
flutter clean

# Build release with obfuscation and split debug info
flutter build windows --release --obfuscate --split-debug-info=build/debug-info

# Get latest git tag for versioning
$tag = git describe --tags --abbrev=0
$cleanTag = $tag -replace "^v", ""
$zipName = "evc-$cleanTag-windows-x64.zip"

# Compress the build output using 7z at max compression
$releaseFolder = "build/windows/x64/runner/Release"
if (Test-Path $releaseFolder) {
    $zipPath = Join-Path $releaseFolder $zipName
    if (Test-Path $zipPath) { Remove-Item $zipPath }
    Push-Location $releaseFolder
    7z a -tzip -mx=9 $zipName *
    Pop-Location
    # Open the built folder in Explorer
    ii $releaseFolder
} else {
    Write-Host "Build output folder not found."
}
