https://azure.com/e/cba3c5bbfb8f4549a8df006d97664f1c

```
def add_row_numbers(sql_text):
    # 各行を分割
    lines = sql_text.strip().split('UNION ALL')
    
    # 各行をトリムして番号を追加
    numbered_lines = []
    for i, line in enumerate(lines, 1):
        # 行をトリムして末尾のカンマを処理
        line = line.strip()
        if line.endswith(','):
            line = line[:-1]
            
        # コメントがある行の処理
        comment_parts = line.split('--')
        if len(comment_parts) > 1:
            base_sql = comment_parts[0].strip()
            comment = '--' + comment_parts[1]
            numbered_lines.append(f"{base_sql}, {i} {comment}")
        else:
            numbered_lines.append(f"{line}, {i}")
    
    # UNION ALLで結合して返す
    return ' UNION ALL\n'.join(numbered_lines)

# 入力SQL
sql_input = """
SELECT 'A', 'A', UNION ALL 
SELECT 'B', 'B',  UNION ALL 
SELECT 'C', 'C', -- 他のスキーマ・テーブルペアを追加
"""

# 実行して結果を表示
result = add_row_numbers(sql_input)
print(result)
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

