```
SqlPackage.exe /Action:Import /SourceFile:"C:\Path\To\Schema1.bacpac" /TargetServerName:"YourServer" /TargetDatabaseName:"ExistingDatabase" /TargetUser:"Username" /TargetPassword:"Password"```
```
解決策としてのオプション：

/p:DatabaseLockTimeout パラメータを設定して長時間のロックを許可
/p:DropObjectsNotInSource=True を使用して、BACPAC にないオブジェクトを削除する（危険なので注意が必要）
/p:BlockOnPossibleDataLoss=False を使用してデータ損失の警告を無視

```
# パラメータ設定
param (
    [string]$serverName = "your-azure-server.database.windows.net",
    [string]$databaseName = "AzureSqlDatabase2",
    [string]$userName = "your-username",
    [string]$password = "your-password",
    [string]$extractedBacpacFolder = "C:\Path\To\Extracted\Bacpac"
)

# SQLサーバーへの接続文字列
$connectionString = "Server=$serverName;Database=$databaseName;User ID=$userName;Password=$password;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"

# extractedBacpacFolder内のDataフォルダを特定
$dataFolder = Join-Path -Path $extractedBacpacFolder -ChildPath "Data"

# BCP関連ファイルを取得
$bcpFiles = Get-ChildItem -Path $dataFolder -Filter "*.bcp"

# テーブル情報を含むmodel.xmlファイル
$modelXmlPath = Join-Path -Path $extractedBacpacFolder -ChildPath "model.xml"
[xml]$modelXml = Get-Content -Path $modelXmlPath

# model.xmlからテーブルマッピング情報を取得
$tableMapping = @{}
$modelXml.SelectNodes("//DataSet") | ForEach-Object {
    $tableName = $_.Name
    $schemaName = ($_.Schema, "dbo" -ne $null)[0]
    $bcpFileName = $_.Value.SelectNodes("./BcpRow")[0].Attributes["Bcp"].Value
    
    $tableMapping[$bcpFileName] = @{
        "Schema" = $schemaName
        "Table" = $tableName
    }
}

# SQLクエリ実行関数
function Execute-SqlQuery {
    param (
        [string]$query
    )
    
    $connection = New-Object System.Data.SqlClient.SqlConnection($connectionString)
    $command = New-Object System.Data.SqlClient.SqlCommand($query, $connection)
    
    try {
        $connection.Open()
        $command.ExecuteNonQuery()
    }
    catch {
        Write-Error "SQL実行エラー: $_"
    }
    finally {
        $connection.Close()
    }
}

Write-Host "外部キー制約を無効化しています..."
Execute-SqlQuery -query "EXEC sp_MSforeachtable 'ALTER TABLE ? NOCHECK CONSTRAINT ALL'"

# 各BCPファイルに対してデータをインポート
foreach ($bcpFile in $bcpFiles) {
    $bcpFileName = $bcpFile.Name
    
    if ($tableMapping.ContainsKey($bcpFileName)) {
        $schemaName = $tableMapping[$bcpFileName].Schema
        $tableName = $tableMapping[$bcpFileName].Table
        $fullTableName = "[$schemaName].[$tableName]"
        
        Write-Host "インポート: $fullTableName (ファイル: $bcpFileName)..."
        
        # IDENTITY列があるか確認
        $identityCheckQuery = "SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = '$schemaName' AND TABLE_NAME = '$tableName' AND COLUMNPROPERTY(OBJECT_ID('$schemaName.$tableName'), COLUMN_NAME, 'IsIdentity') = 1"
        $connection = New-Object System.Data.SqlClient.SqlConnection($connectionString)
        $command = New-Object System.Data.SqlClient.SqlCommand($identityCheckQuery, $connection)
        $connection.Open()
        $identityColumn = $command.ExecuteScalar()
        $connection.Close()
        
        # テーブルの全データを削除（既存データとの競合を避けるため）
        Execute-SqlQuery -query "DELETE FROM $fullTableName"
        
        if ($identityColumn) {
            # IDENTITY挿入を有効化
            Execute-SqlQuery -query "SET IDENTITY_INSERT $fullTableName ON"
        }
        
        # BCPコマンドを実行してデータをインポート
        $bcpFilePath = $bcpFile.FullName
        $bcpCommand = "bcp $schemaName.$tableName in '$bcpFilePath' -S '$serverName' -d '$databaseName' -U '$userName' -P '$password' -c -E"
        
        try {
            Invoke-Expression $bcpCommand
        }
        catch {
            Write-Error "BCPエラー: $_"
        }
        
        if ($identityColumn) {
            # IDENTITY挿入を無効化
            Execute-SqlQuery -query "SET IDENTITY_INSERT $fullTableName OFF"
        }
    }
    else {
        Write-Warning "マッピング情報がみつかりませんでした: $bcpFileName"
    }
}

Write-Host "外部キー制約を再有効化しています..."
Execute-SqlQuery -query "EXEC sp_MSforeachtable 'ALTER TABLE ? WITH CHECK CHECK CONSTRAINT ALL'"

Write-Host "インポート完了"```
