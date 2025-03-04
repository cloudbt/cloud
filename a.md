
```
param(
    [Parameter(Mandatory=$true)]
    [string]$storageAccount,
    
    [Parameter(Mandatory=$true)]
    [string]$containerName,
    
    [string]$outputFile = "AzureResult.txt",
    
    [string]$maxResults = "*"  # 全てのBlobを取得するために "*" を使用
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

# 結果を保存する配列を初期化
$allBlobs = @()
$marker = $null

# 継続トークンを使って全てのBlobを取得するループ
do {
    if ($marker) {
        $blobList = az storage blob list `
            --container $containerName `
            --connection-string $connectionString `
            --num-results 5000 `
            --marker $marker `
            --query "[].name" `
            --output tsv
        
        # 継続トークンを取得（最後の行）
        $output = $blobList -split "`n"
        if ($output.Count -gt 0) {
            $marker = $output[-1]
            # マーカー行を除外
            $blobNames = $output[0..($output.Count-2)]
        } else {
            $marker = $null
            $blobNames = @()
        }
    } else {
        $blobList = az storage blob list `
            --container $containerName `
            --connection-string $connectionString `
            --num-results 5000 `
            --query "[].name" `
            --output tsv
        
        # 継続トークンを確認
        $output = $blobList -split "`n"
        if ($output.Count -eq 5000) {
            # 最大数に達した場合、最後の行が継続トークン
            $marker = $output[-1]
            $blobNames = $output[0..($output.Count-2)]
        } else {
            $marker = $null
            $blobNames = $output
        }
    }
    
    # 取得したBlobを配列に追加
    $allBlobs += $blobNames
    
    Write-Host "Retrieved $($blobNames.Count) blobs. Total so far: $($allBlobs.Count)"
    
} while ($marker)

# 拡張子でフィルタリング
$filteredBlobs = $allBlobs | Where-Object { $_ -match '\.(txt|xlsm|xls)$' }

# 結果をファイルに書き込み
$filteredBlobs | Out-File -FilePath $outputFile -Encoding utf8

$fileCount = $filteredBlobs.Count
Write-Host "Total files with .txt, .xlsm, or .xls extensions found: $fileCount"
Write-Host "File list saved to: $outputFile"
```
