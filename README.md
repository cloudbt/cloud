# cloud

![image](https://github.com/user-attachments/assets/47be2ff0-ee8f-4e26-85e5-07b1458a0306)

GitHubのデプロイキー（Deploy Keys）を使用しても、ブランチ保護ルールでプルリクエストが必須とされている場合、main ブランチに直接プッシュすることはできません。ブランチ保護ルールは、リポジトリへのアクセス方法に関係なく適用されます。つまり、SSHキー（デプロイキーを含む）やHTTPSを使用した場合でも、保護されたブランチへの直接プッシュは制限されます。

理由:

ブランチ保護ルールの適用範囲: ブランチ保護ルールは、ユーザーやキーの種類に関係なく適用されます。デプロイキーは特定のリポジトリへのアクセスを許可しますが、ブランチ保護ルールを無視することはできません。

GitHub AppまたはBotユーザーを使用してブランチ保護ルールで特定のGitHub AppまたBotユーザーに対してプルリクエストのバイパスを許可する設定を行います。
GitHub AppまたはBotユーザーを使用して、AWS CodeBuildから main ブランチに直接プッシュするには、以下の手順が必要です。

GitHub AppまたはBotユーザーの作成: 適切な権限を持つエンティティを作成します。

ブランチ保護ルールの設定: 特定のアクターに対してプルリクエストのバイパスを許可します。

AWS CodeBuildの設定: 認証情報を安全に管理し、ビルドスクリプトでGitの認証とプッシュを行います。


cat id_github |base64 |tr -d '\n'


KEYPAIR_NAME=INFRA-DELOY-KEY
$ aws secretsmanager create-secret \
    --name ${KEYPAIR_NAME} \
    --secret-binary file://.SSHKEY

    
https://blog.serverworks.co.jp/CodeBuild_Github_repo


https://stackoverflow.com/questions/65349224/aws-codebuild-with-github-enterprise-deploy-keys-asking-for-passphrase
https://stackoverflow.com/questions/42712542/how-to-auto-deploying-git-repositories-with-submodules-on-aws/54318204#54318204

このコマンドは、パスフレーズなしで新しい SSH 認証鍵 workingdir/id_github を作成します。SSH 認証鍵がパスフレーズで保護されている場合、Cloud Build はその鍵を使用できません。
https://cloud.google.com/build/docs/access-github-from-build?hl=ja


AWS：access-tokens-github
https://docs.aws.amazon.com/codebuild/latest/userguide/access-tokens-github.html
https://docs.aws.amazon.com/codebuild/latest/userguide/asm-create-secret.html

server-type: Required value. The source provider used for this credential. Valid values are GITHUB, BITBUCKET, GITHUB_ENTERPRISE, GITLAB, and GITLAB_SELF_MANAGED.

auth-type: Required value. The type of authentication used to connect to a repository. Valid values are OAUTH, BASIC_AUTH, PERSONAL_ACCESS_TOKEN, CODECONNECTIONS, and SECRETS_MANAGER. For GitHub, only PERSONAL_ACCESS_TOKEN is allowed. BASIC_AUTH is only allowed with Bitbucket app password.

should-overwrite: Optional value. Set to false to prevent overwriting the repository source credentials. Set to true to overwrite the repository source credentials. The default value is true.



https://stackoverflow.com/questions/57382873/aws-codebuild-github-deploy-keys

CodeBuild doesn't natively support deploy keys. It is on our product backlog and is a feature that we will likely support in a future release.

In order to use your existing deploy key in CodeBuild, please follow the instruction that Adrian has highlighted in https://adrianhesketh.com/2018/05/02/go-private-repositories-and-aws-codebuild/. You will need to setup the key in parameter-store and use that in your buildspec.

You can use the source type as "no_source", since you would be doing the source cloning with the deploy key in this case.


version: 0.2
env:
  secrets-manager:
    INFRA_DELOY_KEY: dev/asp/SSH_PRIVATE_KEY:SSH_PRIVATE_KEY

phases:
  pre_build:
    commands:
      - mkdir -p ~/.ssh && chmod 0700 ~/.ssh
      - echo "${#INFRA_DELOY_KEY}"
      - echo "test" | base64
      - echo "${INFRA_DELOY_KEY}" | base64 -d > ~/.ssh/id_rsa && chmod 0400 ~/.ssh/id_rsa
      - md5sum ~/.ssh/id_rsa
      - ssh-keyscan github.com >> ~/.ssh/known_hosts
      - ls -lat
      - cat .git/config
      - git config --global user.name "cloudbt"
      - git config --global user.email "hzwang562@gmail.com"
      
  build:
    commands:
      #- touch "test_file.txt"
      #- git add "test_file.txt"
      #- git commit -m "add test_file.txt"
      - rm -f "test_file.txt"
      - git commit -am "delete test_file.txt"
  post_build:
    commands:
      #- git push https://${GITHUB_PAT_Terraform}@github.com/yamazoon0207/test-terraform.git main:main
      #- git push git@github.com:cloudbt/blue.git main:main
      - git push git@github.com:cloudbtjp/yellow.git main:main


      

