■バックアップ取得
docker exec -it php8.2_db bash
mysqldump -u root -p --all-databases > 20241127_backup.sql
docker cp php8.2_db:/20241127_backup.sql /var/develop/dockers/php8.2/

■置換についての内容
・INSERT文を角括弧をバッククオートに置換
・SET IDENTITY_INSERT構文の削除
・N'...'を単純なシングルクォート形式の文字列に置換
・CAST(0x0000985800000000 AS DateTime)を'2004-03-01 00:00:00'形式に置換