https://azure.com/e/cba3c5bbfb8f4549a8df006d97664f1c

```
リクエスト数のコスト

100万リクエストを超えた場合、追加リクエストには料金が発生します
東京リージョンでは、100万リクエストを超える分は100万リクエストあたり約0.20ドルです
2000リクエストの場合：2000 ÷ 1,000,000 × 0.20ドル ≈ 0.0004ドル
日本円に換算（1ドル≒149円と仮定）：0.0004ドル × 149円 ≈ 0.06円

実行時間のコスト

実行時間：2000回 × 1.5秒 = 3000秒
128MBメモリ（0.125GB）を使用すると仮定：0.125GB × 3000秒 = 375 GB秒
東京リージョンのLambda料金：約0.0000167ドル/GB秒
日本円に換算：375 GB秒 × 0.0000167ドル/GB秒 × 149円/ドル ≈ 0.93円

ここでは400,000 GB秒の無料枠内であると仮定します。もし無料枠も超えている場合は、この実行時間のコストも加算されます。
総コスト見積もり（100万リクエスト超過の場合）：約0.06円（リクエスト）+ 0円（実行時間、無料枠内）= 約0.06円
```

```
WITH TablePairs (SchemaName, TableName, RowNum) AS (
    SELECT 'A', 'A', 1 UNION ALL
    SELECT 'B', 'B', 2 UNION ALL
    SELECT 'C', 'C', 3 UNION ALL
    SELECT 'D', 'D', 4 -- 他のスキーマ・テーブルペアを追加
)
SELECT tp.SchemaName AS InputSchema,
       tp.TableName AS InputTable,
       t.TABLE_SCHEMA AS ActualSchema,
       t.TABLE_NAME AS ActualTable,
       CASE 
           WHEN t.TABLE_NAME IS NULL THEN 'Not Exists'
           WHEN tp.TableName COLLATE Latin1_General_BIN = t.TABLE_NAME THEN 'Match'
           ELSE 'Case Difference'
       END AS NameComparison,
       CASE WHEN t.TABLE_NAME IS NOT NULL THEN 'Exists' ELSE 'Not Exists' END AS Status
FROM TablePairs tp
LEFT JOIN INFORMATION_SCHEMA.TABLES t 
    ON LOWER(tp.SchemaName) = LOWER(t.TABLE_SCHEMA)
    AND LOWER(tp.TableName) = LOWER(t.TABLE_NAME)
ORDER BY tp.RowNum;

```


```
WITH TablePairs (SchemaName, TableName, RowNum) AS (
    SELECT 'A', 'A', 1 UNION ALL
    SELECT 'B', 'B', 2 UNION ALL
    SELECT 'C', 'C', 3 -- 他のスキーマ・テーブルペアを追加
)
SELECT tp.SchemaName AS InputSchema,
       tp.TableName AS InputTable,
       t.TABLE_SCHEMA AS ActualSchema,
       t.TABLE_NAME AS ActualTable,
       CASE WHEN t.TABLE_NAME IS NOT NULL THEN 'Exists' ELSE 'Not Exists' END AS Status
FROM TablePairs tp
LEFT JOIN INFORMATION_SCHEMA.TABLES t 
    ON LOWER(tp.SchemaName) = LOWER(t.TABLE_SCHEMA)
    AND LOWER(tp.TableName) = LOWER(t.TABLE_NAME)
ORDER BY tp.RowNum;

```


```
WITH TablePairs (SchemaName, TableName) AS (
    SELECT 'A', 'A' UNION ALL
    SELECT 'B', 'B' UNION ALL
    SELECT 'C', 'C' -- 他のスキーマ・テーブルペアを追加
)
SELECT tp.SchemaName AS InputSchema,
       tp.TableName AS InputTable,
       t.TABLE_SCHEMA AS ActualSchema,
       t.TABLE_NAME AS ActualTable,
       CASE WHEN t.TABLE_NAME IS NOT NULL THEN 'Exists' ELSE 'Not Exists' END AS Status
FROM TablePairs tp
LEFT JOIN INFORMATION_SCHEMA.TABLES t 
    ON LOWER(tp.SchemaName) = LOWER(t.TABLE_SCHEMA)
    AND LOWER(tp.TableName) = LOWER(t.TABLE_NAME);
```

```
WITH TablePairs (SchemaName, TableName) AS (
    SELECT 'A', 'A' UNION ALL
    SELECT 'B', 'B' UNION ALL
    SELECT 'C', 'C' -- 他のスキーマ・テーブルペアを追加
)
SELECT 
    tp.SchemaName AS InputSchema, 
    tp.TableName AS InputTable, 
    t.TABLE_SCHEMA AS ActualSchema, 
    t.TABLE_NAME AS ActualTable,
    CASE 
        WHEN t.TABLE_NAME IS NOT NULL THEN 'Exists' 
        ELSE 'Not Exists' 
    END AS Status
FROM TablePairs tp
LEFT JOIN INFORMATION_SCHEMA.TABLES t 
    ON LOWER(tp.SchemaName) = LOWER(t.TABLE_SCHEMA) 
    AND LOWER(tp.TableName) = LOWER(t.TABLE_NAME);

```



```
WITH TablePairs (SchemaName, TableName) AS (
    SELECT 'A', 'A' UNION ALL
    SELECT 'B', 'B' UNION ALL
    SELECT 'C', 'C' -- 他のスキーマ・テーブルペアを追加
)
SELECT tp.SchemaName, tp.TableName, 
       CASE WHEN t.TABLE_NAME IS NOT NULL THEN 'Exists' ELSE 'Not Exists' END AS Status
FROM TablePairs tp
LEFT JOIN INFORMATION_SCHEMA.TABLES t 
    ON tp.SchemaName = t.TABLE_SCHEMA 
    AND tp.TableName = t.TABLE_NAME;

```

