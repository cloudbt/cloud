https://azure.com/e/cba3c5bbfb8f4549a8df006d97664f1c



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

