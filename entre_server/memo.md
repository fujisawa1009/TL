■バックアップ取得
docker exec -it php8.2_db bash
mysqldump -u root -p --all-databases > 20241127_backup.sql
docker cp php8.2_db:/20241127_backup.sql /var/develop/dockers/php8.2/

■置換についての内容(change.rb)
・先に不要な行のパターンにマッチする場合は行ごと削除する。
・一時的にINSERT文を蓄積するcurrent_insert変数にINSERT始まりの場合は結合
またINSERT始まりでなく、かつcurrent_insert変数が空でない場合も結合

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