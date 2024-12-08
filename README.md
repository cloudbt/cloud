```
  input_transformer {
    input_paths = {
      username   = "$.detail.requestParameters.userName"
      creator    = "$.detail.userIdentity.arn"
      timestamp  = "$.time"
      source_ip  = "$.detail.sourceIPAddress"
      account_id = "$.account"
    }
    input_template = <<-EOT
      "新しいIAMユーザーが作成されたことを検知しました。詳細は以下をご確認ください。"
      "- 作成されたユーザー名: <username>"
      "- 作成者: <creator>"
      "- 作成日時(UTC): <timestamp>"
      "- 発信元IP: <source_ip>"
      "- AWSアカウントID: <account_id>"
    EOT
  }
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
