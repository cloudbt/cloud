```

Thank you for creating the procedure.
I confirmed with Mr. Tokuyama that it is important to note that after executing a scan with Microsoft Purview, a metadata registration process is always required. Since that procedure is currently not described in the document, please add the following two points to the procedure.

A clear explanation that metadata registration is mandatory after each scan.
Detailed instructions for performing metadata registration using Python tools.


Please confirm with Mr. A as he is familiar with metadata registration using Python tools
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
