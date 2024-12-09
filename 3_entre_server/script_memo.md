■バックアップ
docker exec -it php8.2_db bash
mysqldump -u root -p --all-databases > 20241127_backup.sql
docker cp php8.2_db:/20241127_backup.sql /var/develop/dockers/php8.2/

■sqlファイル実行
# 事前にinput_system.sqlファイルはnkfで変換が必要
【完了】nkf -w --overwrite output_system.sql


#　docker環境にコピー
【完了】docker cp /var/develop/dockers/ruby/TL/entre_server/output_system.sql php8.2_db:/

#　docker環境に入ってsqlファイル実行
docker exec -it php8.2_db bash
【完了】mysql -u root -p System < output_system.sql


# エラーは戻って行数指定確認
awk NR==9610 check_output_system.sql

■置換についての内容(change.rb)
[おまじない]
nkf -w --overwrite input_system.sql
ruby change.rb   # 何行か、elseに入っている。末尾）で終わって切れるパターン
check_output_system.sqlに名前変更してローカル確認
mv output_system.sql check_output_system.sql
BEGIN;　と　ROLLBACK;　-- COMMIT;　を追加する
# ローカルでファイルを分割して上の手順へ進む
ROLLBACK;
-- COMMIT;

[内容]
・先に不要な行のパターンにマッチする場合は行ごと削除する。
・一時的にINSERT文を蓄積するcurrent_insert変数にINSERT始まりの場合は結合
またINSERT始まりでなく、かつcurrent_insert変数が空でない場合も結合
※上記以外の場合とりあえずターミナル出力して漏れを検知？

・そのまま、INSERT文の終わりである ) が閉じている場合に以下処理を行う
  -  文末にセミコロンを追加
  -  スキーマ名削除
  -  角括弧をバッククォートへ置換
  -  N'...'を'...'へ置換
  -  CAST(0x...) を日付に置換
  -  ファイルに出力してバッファをリセットする

事前準備として
・INSERT文を角括弧をバッククオートに置換
・SET IDENTITY_INSERT構文の削除
・N'...'を単純なシングルクォート形式の文字列に置換
・CAST(0x0000985800000000 AS DateTime)を'2004-03-01 00:00:00'形式に置換

■DBお掃除用クエリ
-- SELECT * FROM `社内アカウント`;
DELETE FROM `社内アカウント`;
-- SELECT * FROM `ライセンスシート`;
DELETE FROM `ライセンスシート`;
-- SELECT * FROM `YOUGO`;
DELETE FROM `YOUGO`;
DELETE FROM `数値`;
-- 以下はテーブルかカラムが足りないため確認中
-- DESCRIBE `YOUGO`;

■ここは手動で追加する
BEGIN;
--処理内容
ROLLBACK;
-- COMMIT;

■DBの全てのデータを削除するコマンド
SET FOREIGN_KEY_CHECKS = 0;

SELECT CONCAT('TRUNCATE TABLE ', TABLE_NAME, ';') AS truncate_command
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'System';

# 結果をコピーして実行する
TRUNCATE TABLE HO_M_M;
TRUNCATE TABLE H1006;
TRUNCATE TABLE LIST6;
TRUNCATE TABLE MAIN;
TRUNCATE TABLE BUNKATU_H_D;
TRUNCATE TABLE KAIYAKU_T;
TRUNCATE TABLE ETP_KANRI;
TRUNCATE TABLE F1002;
TRUNCATE TABLE MSYO1;
TRUNCATE TABLE TTEAM;
TRUNCATE TABLE H_SAPORT;
TRUNCATE TABLE LIST2;
TRUNCATE TABLE HO_SINCHOKU;
TRUNCATE TABLE 社内アカウント;
TRUNCATE TABLE LTABLE_T;
TRUNCATE TABLE LIST1;
TRUNCATE TABLE HASSOU;
TRUNCATE TABLE J_T;
TRUNCATE TABLE H1000;
TRUNCATE TABLE T_JMD;
TRUNCATE TABLE 数値;
TRUNCATE TABLE RIREKI;
TRUNCATE TABLE User;
TRUNCATE TABLE dbo_LTABLE_T;
TRUNCATE TABLE H1003;
TRUNCATE TABLE `TABLE-ETM20090406`;
TRUNCATE TABLE KAIYAKU_HTD;
TRUNCATE TABLE PLUS;
TRUNCATE TABLE YOUGO;
TRUNCATE TABLE `TABLE`;
TRUNCATE TABLE `OFFICE`;
TRUNCATE TABLE MSYAID;
TRUNCATE TABLE MSYO;
TRUNCATE TABLE M_CONS;
TRUNCATE TABLE LOGS_LO_CSV_J;
TRUNCATE TABLE PLUS_DOMAIN;
TRUNCATE TABLE KAIYAKU_SEARCH_KEI;
TRUNCATE TABLE H1005;
TRUNCATE TABLE SKY_T;
TRUNCATE TABLE TABLE_ETM20090406;
TRUNCATE TABLE GYOUSHU;
TRUNCATE TABLE LA_T;
TRUNCATE TABLE ライセンスシート;
TRUNCATE TABLE MASTER;
TRUNCATE TABLE KAIYAKU_TD;
TRUNCATE TABLE TABLE_ETM;
TRUNCATE TABLE SINCHOKU_NM;
TRUNCATE TABLE TR_M;
TRUNCATE TABLE S0100;
TRUNCATE TABLE F1003;
TRUNCATE TABLE BK_T;
TRUNCATE TABLE USER_T;
TRUNCATE TABLE SINCHOKU;
TRUNCATE TABLE STAGE;
TRUNCATE TABLE LOGS_LO_CSV_S;
TRUNCATE TABLE RTUP_STATUS;
TRUNCATE TABLE M_VARI;
TRUNCATE TABLE TABLE_ETM20090420;
TRUNCATE TABLE HO_M_P;
TRUNCATE TABLE LIST3;
TRUNCATE TABLE SH_M;
TRUNCATE TABLE RTUP_T;
TRUNCATE TABLE TAIYO_RIREKI;
TRUNCATE TABLE T_HM;
TRUNCATE TABLE H1004;
TRUNCATE TABLE KAIYAKU_SEARCH_TAN;
TRUNCATE TABLE LOGS_LO;
TRUNCATE TABLE IP_SEARCH;
TRUNCATE TABLE LA_M;
TRUNCATE TABLE H1001;
TRUNCATE TABLE HN_T;
TRUNCATE TABLE TCYOKHAN;
TRUNCATE TABLE HO_M_S;
TRUNCATE TABLE RIREKI_DM;
TRUNCATE TABLE DNS_IRAI;
TRUNCATE TABLE LIST4;
TRUNCATE TABLE HO_M_A;
TRUNCATE TABLE BUNKATU_T;
TRUNCATE TABLE M_SR;
TRUNCATE TABLE SHUBETU;
TRUNCATE TABLE DOMAIN_USER;
TRUNCATE TABLE STATUS;
TRUNCATE TABLE HO_T_T;
TRUNCATE TABLE T_JM;
TRUNCATE TABLE ETM_BBS;
TRUNCATE TABLE GMO_KANRI;
TRUNCATE TABLE M_SHOUHIN;
TRUNCATE TABLE F1001;
TRUNCATE TABLE LIST5;
TRUNCATE TABLE KAIYAKU_STATUS;
TRUNCATE TABLE `TABLE-ETM`;
TRUNCATE TABLE LOGS_EX;
TRUNCATE TABLE DOMAIN;
TRUNCATE TABLE HO_M_U;
TRUNCATE TABLE BUNKATU_S_D;
TRUNCATE TABLE INFO;
TRUNCATE TABLE run;
TRUNCATE TABLE IKOU_IRAI;


# 最後に外部キー制約の再有効化
SET FOREIGN_KEY_CHECKS = 1;


DELETE * FROM `TABLE-ETM20090406`
SELECT * FROM `TAIYO_RIREKI`
SELECT * FROM `TCYOKHAN`
SELECT * FROM `USER_T`
SELECT * FROM `YOUGO`