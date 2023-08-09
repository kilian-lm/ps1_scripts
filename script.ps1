param (
    [string]$sourceDir,
    [string]$destDir
)

function Write-ProgressBar {
    param (
        [int]$percent
    )
    $bar = "=" * $percent + " " * (100 - $percent)
    Write-Host -NoNewline "`r[$bar] $percent%"
}

function Copy-Files {
    param (
        [string]$source,
        [string]$destination
    )

    $csvFile = "time_exceeded_files.csv"
    "Filename,Size" | Out-File $csvFile

    $files = Get-ChildItem -Path $source -Recurse -File
    foreach ($file in $files) {
        $destFile = $destination + ($file.FullName).Substring($source.length)
        $destDir = [System.IO.Path]::GetDirectoryName($destFile)

        if (Test-Path -Path $destFile) {
            Write-Host "File already exists, skipping: $($file.FullName)"
            continue
        }

        if (!(Test-Path -Path $destDir)) {
            New-Item -Path $destDir -ItemType Directory | Out-Null
        }

        Write-Host "Copying $($file.Name)..."
        $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
        $timeout = $false

        for ($i = 0; $i -le 100; $i++) {
            if ($stopwatch.Elapsed.TotalSeconds -gt 45) {
                $timeout = $true
                break
            }
            Copy-Item -Path $file.FullName -Destination $destFile -ErrorAction SilentlyContinue
            Write-ProgressBar $i
            Start-Sleep -Milliseconds 50
        }

        Write-Host ""

        if ($timeout) {
            $size = (Get-Item -Path $file.FullName).length
            Write-Host "Time exceeded for file: $($file.FullName)"
            "$($file.FullName),$size" | Out-File $csvFile -Append
            Remove-Item -Path $destFile -ErrorAction SilentlyContinue
        }
    }

    Write-Host "Copy process complete."
}

# Validate input parameters
if (!$sourceDir -or !(Test-Path -Path $sourceDir -PathType Container)) {
    Write-Host "Source directory does not exist."
    exit 1
}

if (!$destDir -or !(Test-Path -Path $destDir -PathType Container)) {
    Write-Host "Destination directory does not exist."
    exit 1
}

Copy-Files -source $sourceDir -destination $destDir


# .\script.ps1 -sourceDir "C:\Users\kilia\Desktop\main" -destDir "D:\"
