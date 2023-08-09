# Import Chocolatey Module (assumes Chocolatey is installed)
Import-Module "$env:ChocolateyInstall\helpers\chocolateyInstaller.psm1"

# Path to the CSV file
$csvPath = "C:\Users\kilia\Desktop\programms_reformat.csv"

# Create CSV header
"Program Name,Available on Package Manager,Package Manager,PowerShell Command" | Out-File $csvPath

# Get all installed programs
$programs = Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* |
             Where-Object { $_.DisplayName } |
             Select-Object DisplayName

foreach ($program in $programs) {
    $programName = $program.DisplayName
    $available = $false
    $packageManager = ""
    $command = ""

    # Check Chocolatey for package
    $chocoPackage = choco list --local-only $programName 2>$null
    if ($chocoPackage -notlike "0 packages installed.") {
        $available = $true
        $packageManager = "Chocolatey"
        $command = "choco install $programName"
    }

    # Output to CSV
    "$programName,$available,$packageManager,$command" | Out-File $csvPath -Append
}

Write-Host "CSV file created at $csvPath"
