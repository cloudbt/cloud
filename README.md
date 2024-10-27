# cloud

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
