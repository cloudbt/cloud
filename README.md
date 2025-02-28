```
{
  "repoUrl": "$.detail.repository.clone_url",
  "sourceVersion": "$.detail.ref",
  "resolvedSourceVersion": "$.detail.custom_resolved_version"
}
```


```
{
  "projectName": "my-codebuild-project",
  "environmentVariablesOverride": [
    {
      "name": "CODEBUILD_SOURCE_REPO_URL",
      "value": "<repoUrl>",
      "type": "PLAINTEXT"
    },
    {
      "name": "CODEBUILD_SOURCE_VERSION",
      "value": "<sourceVersion>",
      "type": "PLAINTEXT"
    },
    {
      "name": "CODEBUILD_RESOLVED_SOURCE_VERSION",
      "value": "<resolvedSourceVersion>",
      "type": "PLAINTEXT"
    }
  ]
}
```

```
version: 0.2

phases:
  install:
    runtime-versions:
      nodejs: 14
  pre_build:
    commands:
      - echo "Building repository: $CODEBUILD_SOURCE_REPO_URL"
      - echo "Source version: $CODEBUILD_SOURCE_VERSION"
      - echo "Resolved source version: $CODEBUILD_RESOLVED_SOURCE_VERSION"
      
      # イベントタイプに応じた処理
      - |
        if [[ $CODEBUILD_RESOLVED_SOURCE_VERSION == refs/heads/* ]]; then
          # Push イベントの場合
          BRANCH_NAME=$(echo $CODEBUILD_RESOLVED_SOURCE_VERSION | sed 's|refs/heads/||')
          echo "Building branch: $BRANCH_NAME"
          
          # ブランチ名に基づいた処理
          if [ "$BRANCH_NAME" = "main" ]; then
            echo "Building production"
            export ENV=production
          elif [ "$BRANCH_NAME" = "develop" ]; then
            echo "Building staging"
            export ENV=staging
          else
            echo "Building development"
            export ENV=development
          fi
          
        elif [[ $CODEBUILD_RESOLVED_SOURCE_VERSION == pr/* ]]; then
          # PR イベントの場合
          PR_NUMBER=$(echo $CODEBUILD_RESOLVED_SOURCE_VERSION | sed 's|pr/||')
          echo "Building PR #$PR_NUMBER"
          export ENV=test
        fi
  build:
    commands:
      - echo "Building for environment: $ENV"
      - npm install
      - npm run build:$ENV
```
