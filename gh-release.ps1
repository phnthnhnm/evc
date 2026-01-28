# Version Input & Validation
 $version = Read-Host "Enter the new version (e.g., 1.15.7)"

# Basic SemVer validation (Major.Minor.Patch)
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

# Stage pubspec.yaml
git add $pubspecPath

# Commit
git commit -m "chore(version): bump version to $version"

# Create Tag
git tag -a $tag -m ""

# Push Commits and Tags
git push
git push --tags

# --- 4. Define Release Notes (Hardcoded Template) ---
 $releaseNotes = @"
## $version

### Added
- 

### Fixed
- 

### Improved
- 
"@

# --- 5. Build & Zip Process ---
Write-Host "Starting Flutter Build..."

# Clean old build files
flutter clean

# Build release with obfuscation and split debug info
flutter build windows --release --obfuscate --split-debug-info=build/debug-info

# Prepare Zip Name
 $zipName = "evc-$version-windows-x64.zip"
 $releaseFolder = "build/windows/x64/runner/Release"

if (Test-Path $releaseFolder) {
    $zipPath = Join-Path $releaseFolder $zipName
    
    # Remove old zip if it exists
    if (Test-Path $zipPath) { Remove-Item $zipPath }
    
    # Compress
    Push-Location $releaseFolder
    7z a -tzip -mx=9 $zipName *
    Pop-Location

    # Create GitHub Release
    
    # Check for GitHub CLI
    if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
        Write-Error "GitHub CLI (gh) is not installed. Please install it from https://cli.github.com/"
        exit 1
    }

    # Retrieve Repo URL
    $repoUrl = git remote get-url origin

    # Create Release
    Write-Host "Creating GitHub Release '$tag'..."
    
    try {
        gh release create $tag `
            --title "$tag" `
            --notes "$releaseNotes" `
            --repo $repoUrl
    } catch {
        Write-Host "Release might already exist. Attempting to upload asset anyway..."
    }

    # Upload Zip
    Write-Host "Uploading $zipName..."
    gh release upload $tag $zipPath --clobber --repo $repoUrl

    # Open Release Edit Page
    # Parse the URL to ensure it is in https format (handles git@ and .git)
    $cleanUrl = $repoUrl -replace "\.git$", ""
    if ($cleanUrl -match "^git@") {
        $cleanUrl = $cleanUrl -replace "git@", "https://" -replace ":", "/"
    }
    $editUrl = "$cleanUrl/releases/edit/$tag"
    
    Write-Host "Opening release edit page in browser..."
    Start-Process $editUrl

    Write-Host "Done! Please fill in the release notes on the opened page."

} else {
    Write-Host "Build output folder not found."
}
