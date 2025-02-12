https://azure.com/e/cba3c5bbfb8f4549a8df006d97664f1c

```
SELECT COUNT(*) AS TableExists
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'A' AND TABLE_NAME = 'A';
SELECT TABLE_SCHEMA, TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE (TABLE_SCHEMA, TABLE_NAME) IN (('A', 'A'), ('B', 'B'), ('C', 'C'));

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

