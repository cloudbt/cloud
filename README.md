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
