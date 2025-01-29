# Azure SQL Database 移行方法

## 1. BACPAC のエクスポート／インポート

最もオーソドックスかつシンプルな方法です。一回きりのフル移行であれば、まずは BACPAC を使った方法を検討するとよいでしょう。

### エクスポート

- **SSMS (SQL Server Management Studio)** などから Azure SQL Database A を「Export Data-tier Application」で BACPAC ファイルにエクスポート
- または **SqlPackage.exe** ツールを使ってコマンドラインでエクスポート
- 出力先は一時的に **Azure Storage（BLOBコンテナ）** などを利用

### インポート

1. B テナント側で空の Azure SQL Database B を用意
2. **SSMS や Azure Portal、SqlPackage.exe** などで先ほどの BACPAC をインポート
3. 途中でドロップダウンなどからファイル元のストレージを指定し、BACPAC からデータベースを構成

### BACPAC 方式の注意点

- **サイズ**: 386GB は大きめのサイズであり、BACPAC のエクスポート・インポート時に時間がかかったり、ローカル経由の場合にはディスク容量やネットワーク帯域・タイムアウトに注意が必要です。
- **ダウンタイム**: BACPAC ファイルを作る際に読み取り専用スナップショットを取得しますが、大きなデータベースだとインポート完了まで本番切り替えを待つ必要があります。ダウンタイムを短くしたい場合は後述の方法を検討してください。
- **異なるテナント間のストレージ**:
  - B テナントが所有するストレージアカウントに BACPAC をコピーしてからインポートする
  - またはローカルに一度落としてインポートする手順になることが多いです。

---

## 2. Azure Data Factory (Copy Data) での移行

テーブル単位でコピーしたい、または **増分移行**（初回フルコピー + 更新分同期）したい場合は Azure Data Factory (ADF) の「Copy Data」機能が便利です。

### 手順

1. **Azure Data Factory** でパイプラインを作成
2. ソースに「Azure SQL Database A」、宛先に「Azure SQL Database B」を設定
3. 同じテナントに ADF が作れない場合、B 側テナントでもしくは別テナントで ADF を新規作成し、Cross-tenant のリンクサービスを設定
4. **Copy Data Activity** で移行対象テーブルを指定して実行
5. 同期したいテーブルが多い場合、パイプラインやマッピングデータフローなどでまとめて実行

### 増分コピー

- テーブルにタイムスタンプやインクリメント用の列が必要です。
- ADF の「Incremental copy」機能を使用することで差分反映が可能です。

### ADF 方式の注意点

- **移行元と移行先のスキーマ差異**: 列構成や制約などが異なる場合、手動でスキーマを合わせる必要があります。
- **パフォーマンス調整**: Copy Data Activity の並列度やバッチサイズの調整で速度やエラーを制御可能です。
- **ランニングコスト**: ADF のパイプライン実行時間分に課金がかかるため、大規模移行時は時間の見積りが重要です。

---

## 3. Data Migration Assistant / Data Migration Service

- **Data Migration Assistant (DMA)**: SQL Server (オンプレ) から Azure SQL Database へのスキーマ分析や互換性評価に使用。
- **Azure Database Migration Service (DMS)**: オンプレや他のクラウドから Azure SQL Database への移行を自動化。
- **Azure 上の DB 間移行**にも利用可能ですが、別テナント間の移行では BACPAC や ADF のほうがシンプルです。

---

## まとめとおすすめ

1. **一度に丸ごと移行**してしまい、移行作業中のダウンタイムが比較的許容できる場合は、**BACPAC（Export/Import）方式**がシンプルでおすすめです。
   - **データサイズが大きい**(386GB)場合:
     - Azure Storage に直接出力する
     - SSMS や SqlPackage.exe のパラメータでタイムアウトやメモリ制限に注意する
     - 必要に応じてテーブルを削減して別BACPACを分割で作成する
2. **ダウンタイムを短くしたい**場合や、**定期的な同期**が必要な場合:
   - **Azure Data Factory** を使用して初回フルコピー + 更新分の段階的コピーを検討

### 推奨手順
- まずは BACPAC を使ったフル移行が通るか検証
- ファイルサイズや実行時間に問題がある場合、ADF の Copy Data を選択
