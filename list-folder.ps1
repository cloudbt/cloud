# .\list-folder.ps1 -FolderPath "./container"
param(
    [Parameter(Mandatory=$true)]
    [string]$FolderPath
)

$scriptPath = $PSScriptRoot
$outputFile = Join-Path $scriptPath "FolderResult.txt"

if (-not (Test-Path -Path $FolderPath -PathType Container)) {
    Write-Error "The specified folder does not exist: $FolderPath"
    exit 1
}

$files = Get-ChildItem -Path $FolderPath -File -Recurse
$fileCount = $files.Count

$files | 
    Sort-Object -Property FullName | 
    Select-Object @{ Name="Path"; Expression={ $_.FullName.Replace((Convert-Path $FolderPath), "").TrimStart('\') } } |
    ForEach-Object { $_.Path } |
    Out-File -FilePath $outputFile -Force -Encoding UTF8

Write-Host "Total files found: $($fileCount.ToString().PadRight(10))"
Write-Host "File list saved to: $outputFile"
