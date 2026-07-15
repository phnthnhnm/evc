Write-Host "Starting Flutter Build..."

flutter clean
flutter build windows --release --obfuscate --split-debug-info=build/debug-info

$releaseFolder = "build/windows/x64/runner/Release"

if (Test-Path $releaseFolder) {
    Write-Host "Build complete."
    Invoke-Item $releaseFolder
} else {
    Write-Host "Build output folder not found."
}
