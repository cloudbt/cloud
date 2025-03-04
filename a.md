
```
param(
    [Parameter(Mandatory=$true)]
    [string]$storageAccount,
    
    [Parameter(Mandatory=$true)]
    [string]$containerName,
    
    [string]$outputFile = "AzureResult.csv"
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

# Get all blobs with name and contentLength (size)
$blobs = az storage blob list `
    --container $containerName `
    --connection-string $connectionString `
    --query "[].{name:name, size:properties.contentLength}" `
    --output json | ConvertFrom-Json

# Filter for specific file extensions, replace / with \, and create CSV content
"ファイル名,ファイルサイズ" | Out-File -FilePath $outputFile -Encoding utf8

$filteredBlobs = $blobs | 
    Where-Object { $_.name -match '\.(txt|xlsm|xls)$' } | 
    Sort-Object -Property name

foreach ($blob in $filteredBlobs) {
    $fileName = $blob.name -replace '/', '\'
    "$fileName,$($blob.size)" | Out-File -FilePath $outputFile -Encoding utf8 -Append
}

$fileCount = $filteredBlobs.Count
Write-Host "Total files with .txt, .xlsm, or .xls extensions found: $fileCount"
Write-Host "File list saved to: $outputFile"
```
