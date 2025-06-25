# Unreal Engine Clean Tool - by Achille Bourgault
# Description: Removes temporary Unreal Engine files, preserving Saved\Config\WindowsEditor only

$projectDir = Get-Location
$derivedDataCache = "$projectDir\DerivedDataCache"
$savedDir = "$projectDir\Saved"
$savedConfig = "$savedDir\Config"
$savedConfigWindowsEditor = "$savedConfig\WindowsEditor"
$intermediate = "$projectDir\Intermediate"

function Print-Info { param($msg) ; Write-Host ""; Write-Host "[INFO]  $msg" -ForegroundColor Cyan }
function Print-Action { param($msg) ; Write-Host ""; Write-Host " » $msg" -ForegroundColor Yellow }
function Print-Success { param($msg) ; Write-Host ""; Write-Host "[OK]    $msg" -ForegroundColor Green }
function Print-Warning { param($msg) ; Write-Host ""; Write-Host "[WARN]  $msg" -ForegroundColor DarkYellow }
function Print-Error { param($msg) ; Write-Host ""; Write-Host "[ERROR] $msg" -ForegroundColor Red }

function Delete-Folder {
    param([string]$folderPath)
    if (Test-Path $folderPath) {
        Print-Action "Deleting: $folderPath"
        Remove-Item -Recurse -Force -Path $folderPath
        Print-Success "Deleted: $folderPath"
    } else {
        Print-Warning "Folder not found: $folderPath"
    }
}

# Clean Saved except Config
function Clean-SavedExceptConfig {
    if (Test-Path $savedDir) {
        Print-Info "Cleaning Saved/ (excluding Config/)..."
        Get-ChildItem -Path $savedDir -Force | ForEach-Object {
            if ($_.FullName -ne $savedConfig) {
                try {
                    Remove-Item -Path $_.FullName -Recurse -Force -ErrorAction Stop
                    Print-Success "Deleted: $($_.FullName)"
                } catch {
                    Print-Error "Failed to delete: $($_.FullName) - $_"
                }
            }
        }
    } else {
        Print-Warning "Saved folder not found."
    }
}

# Clean Saved\Config except WindowsEditor
function Clean-ConfigExceptWindowsEditor {
    if (Test-Path $savedConfig) {
        Print-Info "Cleaning Saved/Config (excluding WindowsEditor/)..."
        Get-ChildItem -Path $savedConfig -Force | ForEach-Object {
            if ($_.FullName -ne $savedConfigWindowsEditor -and -not ($_.FullName.StartsWith($savedConfigWindowsEditor))) {
                try {
                    Remove-Item -Path $_.FullName -Recurse -Force -ErrorAction Stop
                    Print-Success "Deleted: $($_.FullName)"
                } catch {
                    Print-Error "Failed to delete: $($_.FullName) - $_"
                }
            }
        }
    } else {
        Print-Warning "Saved\Config folder not found."
    }
}

# Get single-key choice (robust)
function Get-Choice {
    param([string]$message)
    Write-Host ""
    Write-Host "$message [Y/N]" -ForegroundColor Gray -NoNewline
    $key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    if ($key.Character -ne $null -and $key.Character -match '[A-Za-z]') {
        return $key.Character.ToString().ToUpper()
    } else {
        return ""
    }
}

# ==============================
# Execution Start
# ==============================
Clear-Host
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor DarkGray
Write-Host "         Unreal Engine Clean Tool — Achille Bourgault        " -ForegroundColor White
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor DarkGray

$choice = Get-Choice "Do you want to perform a full cleanup"

if ($choice -eq 'Y') {
    Print-Info "Performing full cleanup..."
    Delete-Folder $derivedDataCache
    Delete-Folder $intermediate
    Clean-SavedExceptConfig
    Clean-ConfigExceptWindowsEditor
    Write-Host ""
    Write-Host "✅ Full cleanup completed successfully." -ForegroundColor Green
} elseif ($choice -eq 'N') {
    if ((Get-Choice "Delete DerivedDataCache?") -eq 'Y') {
        Delete-Folder $derivedDataCache
    }
    if ((Get-Choice "Delete Intermediate folder?") -eq 'Y') {
        Delete-Folder $intermediate
    }
    if ((Get-Choice "Clean Saved/ (excluding Config)?") -eq 'Y') {
        Clean-SavedExceptConfig
    }
    if ((Get-Choice "Clean Config (excluding WindowsEditor)?") -eq 'Y') {
        Clean-ConfigExceptWindowsEditor
    }
    Write-Host ""
    Write-Host "✅ Selected cleanup operations completed." -ForegroundColor Green
} else {
    Print-Warning "No valid choice selected. Operation aborted."
}

Write-Host ""
Pause
