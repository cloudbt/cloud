```
SqlPackage.exe /Action:Import /SourceFile:"C:\Path\To\Schema1.bacpac" /TargetServerName:"YourServer" /TargetDatabaseName:"ExistingDatabase" /TargetUser:"Username" /TargetPassword:"Password"```
```
解決策としてのオプション：

/p:DatabaseLockTimeout パラメータを設定して長時間のロックを許可
/p:DropObjectsNotInSource=True を使用して、BACPAC にないオブジェクトを削除する（危険なので注意が必要）
/p:BlockOnPossibleDataLoss=False を使用してデータ損失の警告を無視

```
SqlPackage.exe /Action:Script /SourceFile:"C:\Path\To\Schema1.bacpac" /OutputPath:"C:\Path\To\Script.sql" /TargetServerName:"YourServer" /TargetDatabaseName:"ExistingDatabase"
```
