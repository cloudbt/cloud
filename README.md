# container-build
```
{
  "source": ["github.com"],
  "detail-type": ["push"],
  "detail": {
    "ref": ["refs/heads/main"],
    "$or": [{
      "head_commit": {
        "added": [{
          "prefix": "dev/asp/iam-createuser-notification/"
        }]
      }
    }, {
      "head_commit": {
        "added": [{
          "prefix": "module/iam-createuser-notification/"
        }]
      }
    }, {
      "head_commit": {
        "removed": [{
          "prefix": "dev/asp/iam-createuser-notification/"
        }]
      }
    }, {
      "head_commit": {
        "removed": [{
          "prefix": "module/iam-createuser-notification/"
        }]
      }
    }, {
      "head_commit": {
        "modified": [{
          "prefix": "dev/asp/iam-createuser-notification/"
        }]
      }
    }, {
      "head_commit": {
        "modified": [{
          "prefix": "module/iam-createuser-notification/"
        }]
      }
    }]
  }
}
```

## tf-apply
```
{
  "source": ["github.com"],
  "detail-type": ["pull_request"],
  "detail": {
    "action": ["closed"],
    "pull_request": {
      "base": {
        "ref": ["main"]
      },
      "merged": [true]
    }
  }
}
```

## tf-plan
```
{
  "source": ["github.com"],
  "detail-type": ["pull_request"],
  "detail": {
    "action": ["opened", "reopened", "synchronize"]
  }
}
```

```
version: 0.2

phases:
  build:
    commands:
      - |
        bash \
          ./codebuild/test.sh

#!/bin/bash/env bash
set -euvx

echo "AWS Region: $AWS_REGION"
echo "CodeBuild Build ARN: $CODEBUILD_BUILD_ARN"
echo "CodeBuild Build ID: $CODEBUILD_BUILD_ID"
echo "CodeBuild Resolved Source Version: $CODEBUILD_RESOLVED_SOURCE_VERSION"
echo "CodeBuild Source Repository URL: $CODEBUILD_SOURCE_REPO_URL"
echo "CodeBuild Source Version: $CODEBUILD_SOURCE_VERSION"
```
