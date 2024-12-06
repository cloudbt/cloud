```
          EXIT_CODE=0
          snyk code test || EXIT_CODE=$?
          echo "Exit code: $EXIT_CODE"
          echo "exit_code=$EXIT_CODE" >> $GITHUB_OUTPUT
          if [ "$EXIT_CODE" = "3" ]; then
            exit 0
          else
            exit $EXIT_CODE
          fi
```

```
graph TD
    A[Start] --> B[Read metadata（include Table and Column name） from Excel]
    B --> C[Search for Table Asset GUID by Table Name]
    C -->|Found| D[Get Table` Columns（=table asset Schema）]
    C -->|Not Found| E[Log Error and Skip]
    D --> F[Find Column Asset GUID by Column name]
    F -->|Found| G[Register/Set Column Managed Attributes]
    F -->|Not Found| E
    G --> H[Success]
    E --> H
    H -->|More Rows| B
    H -->|Done| I[End]

```
