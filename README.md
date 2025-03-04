# container-build
```
# Check if Azure CLI is installed and get the path
function Get-AzureCLIPath {
    $azPath = $null
    
    # Check if az is in PATH
    try {
        $azPath = (Get-Command az -ErrorAction Stop).Source
        Write-Host "Found Azure CLI at: $azPath"
        return $azPath
    } catch {
        Write-Host "Azure CLI not found in PATH"
    }
    
    # Check common installation locations
    $commonPaths = @(
        "C:\Program Files (x86)\Microsoft SDKs\Azure\CLI2\wbin\az.cmd",
        "C:\Program Files\Microsoft SDKs\Azure\CLI2\wbin\az.cmd"
    )
    
    foreach ($path in $commonPaths) {
        if (Test-Path $path) {
            Write-Host "Found Azure CLI at: $path"
            return $path
        }
    }
    
    # Azure CLI not found, download and install
    Write-Host "Azure CLI not found. Downloading..."
    $downloadUrl = "https://azcliprod.blob.core.windows.net/zip/azure-cli-2.70.0-x64.zip"
    $downloadPath = "$env:TEMP\azure-cli.zip"
    $extractPath = "C:\azure-cli"
    
    # Create directory if it doesn't exist
    if (-not (Test-Path $extractPath)) {
        New-Item -ItemType Directory -Path $extractPath -Force | Out-Null
    }
    
    # Download Azure CLI
    Invoke-WebRequest -Uri $downloadUrl -OutFile $downloadPath
    
    # Extract ZIP
    Write-Host "Extracting Azure CLI to $extractPath..."
    Expand-Archive -Path $downloadPath -DestinationPath $extractPath -Force
    
    # Find az.cmd in the extracted files
    $azPath = Get-ChildItem -Path $extractPath -Recurse -Filter "az.cmd" | Select-Object -First 1 -ExpandProperty FullName
    
    if ($azPath) {
        Write-Host "Azure CLI extracted to: $azPath"
        return $azPath
    } else {
        Write-Error "Failed to find az.cmd in the extracted files. Please install Azure CLI manually."
        exit 1
    }
}

# Get Azure CLI path
$AZCLI = Get-AzureCLIPath
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
