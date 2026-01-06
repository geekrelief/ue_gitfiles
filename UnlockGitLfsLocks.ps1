# Ensure Git LFS is installed and available
if (-not (Get-Command "git" -ErrorAction SilentlyContinue)) {
    Write-Error "Git is not installed or not in the PATH."
    exit 1
}

$username = git config user.name
Write-Host "Releasing locks for $username."

# Fetch all locks
$locks = git lfs locks

# Check if there are any locks
if (-not $locks) {
    Write-Host "No locks found in the repository."
    exit 0
}

# Extract lock IDs
$lockEntries = $locks | ForEach-Object {
    if ($_ -match "(\S+)\s+$username\s+ID:(\S+)$") {
       [pscustomobject]@{ File = $matches[1]; ID = $matches[2] }
    }
}

# Check if any lock IDs were found
if (-not $lockEntries) {
    Write-Host "No locks for $username found."
    exit 0
}

# Unlock each file by ID
$paths = [System.Collections.Generic.List[string]]::new()
foreach ($entry in $lockEntries) {
    $paths.Add($entry.File)
}

git lfs unlock $paths

Write-Host "All locks have been released."