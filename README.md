# cloud
ssh-keygen -t rsa -b 4096 -N '' -f id_github -C "email"

cat id_github |base64 |tr -d "\n" |base64 -d


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
