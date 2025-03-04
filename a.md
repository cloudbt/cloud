
```
param(
    [Parameter(Mandatory=$true)]
    [string]$storageAccount,
    
    [Parameter(Mandatory=$true)]
    [string]$containerName,
    
    [string]$outputFile = "AzureResult.txt"
)

# Check Azure CLI login status
$azLogin = az account show 2>&1
if ($azLogin -match "Please run 'az login'") {
    Write-Host "Logging into Azure..."
    az login
}

# Get storage account connection string
$connectionString = az storage account show-connection-string `
    --name $storageAccount `
    --query "connectionString" `
    --output tsv

if (-not $connectionString) {
    Write-Error "Failed to retrieve storage account connection string. Please check account name and permissions."
    exit 1
}

# List all blobs and filter ones with .txt, .xlsm, or .xls extensions
az storage blob list `
    --container $containerName `
    --connection-string $connectionString `
    --query "[].name" `
    --output tsv `
| Where-Object { $_ -match '\.(txt|xlsm|xls)$' } `
| Out-File -FilePath $outputFile -Encoding utf8

$fileCount = Get-Content $outputFile | Measure-Object | Select-Object -ExpandProperty Count
Write-Host "Total files with .txt, .xlsm, or .xls extensions found: $fileCount"
Write-Host "File list saved to: $outputFile"
```
