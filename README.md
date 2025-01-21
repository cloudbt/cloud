name: UbuntuInitialSetup
description: Initial setup for Ubuntu including Japanese language support and timezone settings
schemaVersion: 1.0
phases:
  - name: build
    steps:
      - name: UpdatePackages
        action: ExecuteBash
        inputs:
          commands:
            - sudo apt update -y
            - sudo apt upgrade -y

      - name: InstallJapaneseLanguageSupport
        action: ExecuteBash
        inputs:
          commands:
            - sudo apt-get install -y language-pack-ja-base language-pack-ja ibus-mozc
            - sudo apt-get install -y fonts-takao-pgothic fonts-takao-gothic fonts-takao-mincho

      - name: ConfigureLocaleAndTimezone
        action: ExecuteBash
        inputs:
          commands:
            - sudo localectl set-locale LANG=ja_JP.UTF-8 LANGUAGE="ja_JP:ja"
            - source /etc/default/locale
            - sudo timedatectl set-timezone Asia/Tokyo

      - name: VerifySettings
        action: ExecuteBash
        inputs:
          commands:
            - locale
            - date
            - timedatectl

parameters: []
