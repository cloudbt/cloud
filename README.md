```
# 各フィールドごとにXMLファイルを生成
foreach ($field in $fields) {
    # ファイル名を定義
    $fileName = Join-Path -Path $outputPath -ChildPath "$($field.fullName).field-meta.xml"
    
    # XMLを文字列として生成
    $stringWriter = New-Object System.IO.StringWriter
    $stringWriter.NewLine = "`n"  # LF改行を使用
    
    $settings = New-Object System.Xml.XmlWriterSettings
    $settings.Indent = $true
    $settings.OmitXmlDeclaration = $false
    $settings.Encoding = [System.Text.Encoding]::UTF8
    $settings.NewLineChars = "`n"  # LF改行を使用
    
    $writer = [System.Xml.XmlWriter]::Create($stringWriter, $settings)
    
    # XML宣言を追加
    $writer.WriteStartDocument()
    
    # CustomField要素を作成（namespaceを指定）
    $writer.WriteStartElement("CustomField", $namespaceUri)
    
    # 子要素（namespace無し）
    $writer.WriteElementString("fullName", $field.fullName)
    $writer.WriteElementString("label", $field.label)
    $writer.WriteElementString("required", $field.required.ToString().ToLower())
    $writer.WriteElementString("trackFeedHistory", $field.trackFeedHistory.ToString().ToLower())
    $writer.WriteElementString("type", $field.type)
    
    # CustomField要素を閉じる
    $writer.WriteEndElement()
    
    # ドキュメントを閉じて保存
    $writer.WriteEndDocument()
    $writer.Flush()
    $writer.Close()
    
    # StringWriterから文字列を取得
    $xmlContent = $stringWriter.ToString()
    $stringWriter.Close()
    
    # UTF-8（BOMなし）でファイルに書き込み
    $utf8NoBomEncoding = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($fileName, $xmlContent, $utf8NoBomEncoding)
}```
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
