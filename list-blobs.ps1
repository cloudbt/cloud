# .\list-blobs.ps1 -storageAccount "your_storage_account_name" -containerName "your_container_name" -outputFile "output_path.txt"
# .\list-blobs.ps1 -storageAccount "apstaeplatformdev" -containerName "gcs" -outputFile "AzureResult.txt"
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

# List all blobs (including nested directories)
az storage blob list `
    --container $containerName `
    --connection-string $connectionString `
    --query "[].name" `
    --output tsv `
| ForEach-Object { Split-Path $_ -Leaf } `
| Out-File -FilePath $outputFile -Encoding utf8

Write-Host "Total files found: $(Get-Content $outputFile | Measure-Object | Select-Object -ExpandProperty Count)"
Write-Host "File list saved to: $outputFile"
