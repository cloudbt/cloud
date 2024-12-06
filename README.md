name: Snyk Security Scanning

# push時に実行
on:
  push:

jobs:
  security-scan:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
        with:
          fetch-depth: 0
          
      - name: Setup Snyk
        uses: snyk/actions/setup@master
        
      - name: Run Snyk Code Test
        id: snyk-code-test
        env:
          SNYK_TOKEN: ${{ secrets.SNYK_API_TOKEN }}
        run: |
          EXIT_CODE=0
          snyk code test || EXIT_CODE=$?
          echo $EXIT_CODE
          echo "exit_code=$EXIT_CODE" >> $GITHUB_OUTPUT
          exit $EXIT_CODE
        continue-on-error: true
        
      # 脆弱性が検出された場合、Teamsのチャネル「セキュリティ通知」に通知
      - name: Send Notification to Teams
        if: ${{ steps.snyk-code-test.outputs.exit_code != '0' && steps.snyk-code-test.outputs.exit_code != '3' }}
        run: |
          echo "snyk find issue!"
          echo "Exit code was: ${{ steps.snyk-code-test.outputs.exit_code }}"

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
