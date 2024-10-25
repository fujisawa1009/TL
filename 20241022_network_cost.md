項目
・【完了】SQL Server 2008 R2のService Pack 1 (SP1)と互換性のあるSQL Serverのバージョン調査
・【完了】SQL Server 2008 R2のService Pack 1 (SP1)と互換性のあるMySQLサーバのバージョン調査
・【まだ】SQLサーバのデータ量を期間集計するSQL Server Profiler
＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝
■SQL Server 2008 R2のService Pack 1 (SP1)と互換性のあるSQL Serverのバージョン調査

■現状のアントレ案件DBのSQL Serverのバージョン情報
AP01
Microsoft SQL Server Standard Edition (64-bit)
バージョン：10.50.2550.0
★上記とRDSに互換性のあるバージョンを確認する！
→上記バージョンでのRDS立ち上げ費用（1万円ないで試せるか検証する）

バージョン10.50.2550.0は、SQL Server 2008 R2のService Pack 1 (SP1)に該当する
Amazon RDSで互換性のあるバージョンは、SQL Server 2008 R2となる。

SQL Server 2008 R2: 直接サポートされていますが、サポートは終了しています2。
SQL Server 2012: 互換性がありますが、アップグレードが必要です2。
SQL Server 2014: 互換性があります2。
SQL Server 2016: 互換性があります2。
SQL Server 2017: 互換性があります2。
SQL Server 2019: 互換性があります2。
SQL Server 2022: 最新バージョンであり、互換性があります2。

■重要点
2019年7月9日で延長サポートが切れた、「SQL Server 2008 / 2008 R2」は、最新バージョンである「SQL Server 2019」での互換性レベルがサポートされているため、おおよそスムーズに移行できる。

ただし、互換性レベルが「80 (SQL Server 2000)」や「90 (SQL Server 2005)」に設定されたSQL Server 2008を使用している場合、SQL Server 2014以降ではサポートされない互換性レベルのため、そのまま移行すると、互換性がない部分でエラーが発生する。
そのため、プログラム修正などの対処が必要になってくる

また、※SQL Server 2022にDB復元する際に互換性レベルを100に設定することが重要
ALTER DATABASE YourDatabaseName SET COMPATIBILITY_LEVEL = 100;
＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝
■SQL Server 2008 R2のService Pack 1 (SP1)と互換性のあるMySQLサーバのバージョン調査
SQL Server 2008 R2 SP1 (バージョン10.50.2550.0)から直接MySQLに移行する場合、Amazon RDSでサポートされているMySQLのバージョンは以下の通り

MySQL 5.6
MySQL 5.7
MySQL 8.0
MySQL 8.1（プレビュー版）1

※ただし、データの変換が必要となる。

＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝
■SQLサーバのデータ量を期間集計するSQL Server Profiler
東京から沖縄のSQLサーバにアクセスする際の通信コストを算出するために、SQL Server Profilerを使用してトレースを取得する方法について

ClientProcessID: クライアントプロセスのID
ApplicationName: アプリケーション名
HostName: クライアントのホスト名
LoginName: ログインユーザー名

SQL:BatchCompleted: バッチクエリの完了時に発生します。
SQL:BatchStarting: バッチクエリの開始時に発生します。
RPC:Completed: リモートプロシージャコールの完了時に発生します。
RPC:Starting: リモートプロシージャコールの開始時に発生します。

■トレースの設定手順
SQL Server Profilerを起動し、新しいトレースを作成します。
トレースのプロパティダイアログボックスで、イベントの選択タブをクリックします。
イベントの選択タブで、上記のイベントを選択し、必要な列を追加します。
フィルターの設定: 東京からのアクセスのみをキャプチャするために、
HostNameやApplicationNameでフィルターを設定します。

１０分ほどのテストトレースデータをＳＳＭＳにてサマリしたクエリと結果は以下。
※なお、RDP先のSSMSからのtrcファイルインポート時にユーザ配下のファイルが読み込みできなかったのでC直下にファイル作成して配置した。（上記内容で不毛な15分を過ごした）
 クエリの実行者であるClientProcessID がサーバー自体のSSMSのプロセスと一致している。
よって、クエリや操作がサーバー自身から発行されているため、クライアントマシンからのリモート接続ではなく、サーバー上で行われたもの。ローカル実行されたものは除くため、ClientProcessIDが12784のものは除外。
 
またどのデータベースへのアクセスが多いかなど確認するために
出力データにDatabaseIDとObjectNameを追加して再度トレースを実行した。

■修正したクエリ
-- trc ファイルを一時テーブル #TraceData にインポートする
SELECT *
INTO #TraceData
FROM fn_trace_gettable('C:\yfuji\20241022entre.trc', DEFAULT);
 
-- 読み取りおよび書き込み操作の合計データ量を計算（RPC:CompletedとSQL:BatchCompletedでフィルタ）
SELECT 
    SUM(Reads) AS TotalReads,
    SUM(Writes) AS TotalWrites
FROM #TraceData
WHERE EventClass IN (10, 12) -- 10: RPC:Completed, 12: SQL:BatchCompleted
  AND ClientProcessID <> 12784;
 
-- 一時テーブルの削除
DROP TABLE #TraceData;

■修正後の計算結果 
11655×8÷1000=93MB

Reads 列の値が多い順に上位10件のクエリを表示してみた
■実行したクエリ
-- trc ファイルを一時テーブル #TraceData にインポートする
SELECT *
INTO #TraceData
FROM fn_trace_gettable('C:\yfuji\20241022entre.trc', DEFAULT);
 
-- 読み取りデータ量が多いクエリを特定
SELECT TOP 10
    EventClass,
    TextData,
    ApplicationName,
    LoginName,
    ClientProcessID,
    Reads,
    Writes,
    Duration,
    StartTime,
    EndTime
FROM #TraceData
WHERE EventClass IN (10, 12) -- 10: RPC:Completed, 12: SQL:BatchCompleted
  AND ClientProcessID <> 12784
ORDER BY Reads DESC;
 
-- 一時テーブルの削除
DROP TABLE #TraceData;



＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝