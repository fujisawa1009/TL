■MSSQLシステム管理者(sa 、Windows の管理者権限を持つユーザーで Windows にログオン)
※既定のパスワードとして「Administrator///」が自動で設定されます。 
■MSSQL管理者アカウントのパスワードを変更する手順
sqlcmdを使用する
■SQL Serverのwindows認証とsaでSQL Serverでログイン
・Windows認証、、、BUILTIN\Administratorsにsysadminが設定されており、OSの管理者(AdministratorsグループのユーザーＩＤ)はSQL Serverでも管理者となる。
・saでSQL Serverでログイン、、saにはサーバーロールのsysadminが設定されている。

■SQL serverからMySQLへデータ移行
https://weekend-v.work/archives/640
手順：CSVファイルをデータ型等加工してMySQLのDB上でクエリを実行する
■※SQLServerからMySQLへデータベースを移行する(workbench)
https://tech-tokyobay.manju.tokyo/?p=47
手順：データの移行は、やってません。（後ほど、PHPでゴリゴリ書いてやりました。
DatabaseMigration→SQL Server用のドライバを確認（エディションも）→スキーマ流す