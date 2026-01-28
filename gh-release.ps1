param(
    [switch]$build
)

# --- 1. Git & Version Logic (Only runs if NOT in build-only mode) ---
if (-not $build) {
    # Version Input
    $version = Read-Host "Enter the new version (e.g., 1.15.7)"
    if ($version -notmatch "^\d+\.\d+\.\d+$") {
        Write-Error "Invalid version format. Please use Semantic Versioning (e.g., 1.15.7)."
        exit 1
    }
    $tag = "v$version"

    # Update pubspec.yaml
    $pubspecPath = "pubspec.yaml"
    if (Test-Path $pubspecPath) {
        $newVersionLine = "version: $version"
        (Get-Content $pubspecPath) -replace '^version: .*', $newVersionLine | Set-Content $pubspecPath
        Write-Host "Updated $pubspecPath to $newVersionLine"
    } else {
        Write-Error "pubspec.yaml not found!"
        exit 1
    }

    # Git Operations
    Write-Host "Committing and pushing changes..."
    git add $pubspecPath
    git commit -m "chore(version): bump version to $version"
    git tag -a $tag -m ""
    git push
    git push --tags

    # Define Release Notes
    $releaseNotes = @"
## $version

### Added
- 

### Fixed
- 

### Improved
- 
"@
} else {
    # Build-only mode settings
    Write-Host "Running in Build-Only mode. Skipping Git/Release steps."
    $version = "dev"
}

# --- 2. Build & Zip Process (Runs in both modes) ---
Write-Host "Starting Flutter Build..."

flutter clean
flutter build windows --release --obfuscate --split-debug-info=build/debug-info

# Determine Zip Name
 $zipName = "evc-$version-windows-x64.zip"
 $releaseFolder = "build/windows/x64/runner/Release"

if (Test-Path $releaseFolder) {
    $zipPath = Join-Path $releaseFolder $zipName
    
    if (Test-Path $zipPath) { Remove-Item $zipPath }
    
    Push-Location $releaseFolder
    7z a -tzip -mx=9 $zipName *
    Pop-Location

    # --- 3. Create GitHub Release (Only runs if NOT in build-only mode) ---
    if (-not $build) {
        if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
            Write-Error "GitHub CLI (gh) is not installed."
            exit 1
        }

        $repoUrl = git remote get-url origin
        
        # --- FIX: Robust URL Parsing ---
        $cleanUrl = ""
        
        # Check for SSH format: git@github.com:user/repo.git
        if ($repoUrl -match "^git@(.+):(.+)$") {
            $ghHost = $matches[1]
            $path = $matches[2] -replace "\.git$", ""
            $cleanUrl = "https://$ghHost/$path"
        } 
        # Check for HTTPS format: https://github.com/user/repo.git
        elseif ($repoUrl -match "^https?://") {
            $cleanUrl = $repoUrl -replace "\.git$", ""
        } else {
            Write-Warning "Could not parse git remote URL format automatically."
            $cleanUrl = $repoUrl
        }

        # Create Release
        Write-Host "Creating GitHub Release '$tag'..."
        try {
            gh release create $tag --title "$tag" --notes "$releaseNotes" --repo $cleanUrl
        } catch {
            Write-Host "Release might already exist. Attempting to upload asset anyway..."
        }

        # Upload Zip
        Write-Host "Uploading $zipName..."
        gh release upload $tag $zipPath --clobber --repo $cleanUrl

        # --- Open Release Edit Page ---
        $editUrl = "$cleanUrl/releases/edit/$tag"
        Write-Host "Opening release edit page in browser: $editUrl"
        Start-Process $editUrl
    }

    Write-Host "Process Complete."
    Invoke-Item $releaseFolder

} else {
    Write-Host "Build output folder not found."
}
