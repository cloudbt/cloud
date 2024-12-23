```
Thank you for the document.
We have noticed that the procedures for re-scanning and re-registration are currently provided in separate files. This setup has been noted as inefficient, as it requires referring to multiple documents and increases the risk of missing steps.
To prevent potential omissions and improve operational efficiency,  would it be possible to consolidate all relevant procedures from re-scan to re-registration into a single document.
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
