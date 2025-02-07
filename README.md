

```
RUN apt-get update && apt-get install -y \
    build-essential \
    && rm -rf /var/lib/apt/lists/*
 ```   
Azure VMの要件とコスト見積もりについて、以下のように詳細を検討させていただきます：
必要なVMスペックの推奨構成：

OSイメージ：Windows Server 2022 Datacenter
VMサイズ：Standard D4s v5

vCPU: 4
RAM: 16 GB
一時ストレージ: 32 GB
この構成で大規模なデータベース移行作業（合計約490GB）に対応可能



ディスク構成：

OS用：Premium SSD P10 (128GB)
データ用：Premium SSD P20 (512GB)

MinervaDBとGainsDBの合計が約490GBのため、一時的なバッファも考慮



概算コスト（Southeast Asiaリージョン）：

VM (D4s v5): 約$190/月
OS用ディスク (P10): 約$17/月
データ用ディスク (P20): 約$66/月

合計: 約$273/月
注意点：

データ移行期間のみの一時的な利用を想定
実際のコストは利用期間や為替レートにより変動
帯域幅使用料は含まれていません
価格は2024年1月時点の概算

この構成であれば、SQLデータベースの移行作業を効率的に実行できます。データベースサイズが大きいため、Premium SSDを選択することで、I/Oパフォーマンスを確保しています。




Azure Hybrid Benefitの注意点：

既存の Windows Server ライセンスと Software Assurance が必要
コア数に応じたライセンスの所持が必要
ライセンスの移行に関する規約を遵守する必要あり


MinervaDB（387GB）のみを移行する場合の推奨構成について、以下をお勧めします：
推奨VMスペック：

OSイメージ：Windows Server 2022 Datacenter
VMサイズ：Standard D4s v5 （十分なパフォーマンスと費用対効果のバランス）

vCPU: 4
RAM: 16 GB
一時ストレージ: 32 GB



ディスク構成：

OS用：Premium SSD P10 (128GB)
データ用：Premium SSD P20 (512GB)

387GBのデータ移行に対して、一時ファイルやバッファ領域を考慮



Azure Hybrid Benefit適用後のコスト（SoutheastAsiaリージョン）：

VM (D4s v5): 約$114/月
OS用ディスク (P10): 約$17/月
データ用ディスク (P20): 約$66/月

合計: 約$197/月
理由：

387GBの大規模データベース移行でも安定したパフォーマンスを確保
メモリ16GBにより、SQLSMSの操作や一時的なデータバッファに十分対応
Premium SSDによりディスクI/Oのボトルネックを防止

1つのデータベースのみの移行でも、データサイズが大きいため、同じスペックをお勧めします。これにより、安定した移行作業が可能となります。



SQL Server Migration Assistant (SSMA) は、Oracle・MySQL・DB2・SAP ASE・Access など、SQL Server 以外のデータベースを SQL Server または Azure SQL Database へ移行する際に、スキーマ変換や移行を支援するためのツールです。
SSMA は主に「異種DBからSQL Serverへ移行」するために使われるものであり、SQL Server から SQL Server（あるいは Azure SQL Database 間）をオンラインかつダウンタイムほぼゼロで移行するシナリオには対応していません。

Azure SQL Database 同士で移行したい場合は、Azure Database Migration Service (DMS) や BACPAC のエクスポート・インポート、または Active Geo-Replication / Auto-Failover Groups といった Azure SQL Database 本来の機能を活用して移行する方法が一般的です。

Azure SQL Database 間でダウンタイムを最小化したオンライン移行を行いたい場合は、次のような方法が代表的です。

Azure Database Migration Service (DMS)
“オンライン移行”モードをサポートしており、移行元と移行先間の差分をリアルタイム同期しながら最終的にカットオーバーすることで、ダウンタイムを最小にできます。
オンプレミス SQL Server や他の Azure SQL Database から別の Azure SQL Database への移行にも対応しています。
Active Geo-Replication / Auto-Failover Groups
もともと Azure SQL Database が備えている災害対策機能を利用することで、同期を取りながらフェールオーバーするといった方法もあります（構成や要件によっては活用が難しいケースもあります）。
ポイント

DMS を利用したオンライン移行は、移行開始後に継続的に差分レプリケーションを行い、最終切り替え時のみ数分程度のダウンタイムに抑えることが可能です。
SSMA は異種DB → SQL Serverへの移行支援がメインであり、SQL Server 同士、あるいは Azure SQL Database 間のオンライン差分同期は標準機能として持ちません。


https://learn.microsoft.com/ja-jp/azure/azure-sql/database/database-export?view=azuresql



BACPAC 形式でエクスポートする手段があります。これもオンラインで取得できるため、ダウンタイムはほぼ不要です。
大規模なデータベースで BACPAC をエクスポートする場合には、パフォーマンス面の影響を考慮し、オフピーク時間帯など負荷の少ないタイミングで実施してください。
