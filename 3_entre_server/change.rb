require 'date'

input_file = 'input_system.sql'
output_file = 'output_system.sql'

# クォートや括弧のバランスをチェックする関数
def balanced?(string)
  single_quotes = string.scan(/'/).size.odd? # シングルクォートが奇数なら閉じていない
  parentheses = string.scan(/\(/).size != string.scan(/\)/).size # 括弧の個数が一致しない
  !single_quotes && !parentheses
end

# 16進数の日時データを変換する関数
def hex_to_datetime(hex_value)
  days = hex_value[2, 8].to_i(16)
  seconds = hex_value[10, 8].to_i(16) / 300.0
  base_date = DateTime.new(1900, 1, 1)
  begin
    datetime_value = base_date + days + Rational(seconds, 86400)
  rescue ArgumentError
    # 日付が計算できない場合、デフォルト値を返す
    return '0000-00-00 00:00:00'
  end

  # 変換後の日付が現実的かチェック
  if datetime_value.year > 9999 || datetime_value.year < 1000
    return '0000-00-00 00:00:00' # 不正な場合はデフォルト値を返す
  end
  # MySQLのDATETIME形式（YYYY-MM-DD HH:MM:SS）に変換
  datetime_value.strftime('%Y-%m-%d %H:%M:%S')
end

# INSERT文を処理する関数
def process_insert(insert_statement)
  # 必要な変換処理を適用
  insert_statement.gsub!(/\)\z/, ');') # ); に変換
  insert_statement.sub!(/\[.*?\]\./, '') # スキーマ削除
  insert_statement.gsub!(/\[(.*?)\]/, '`\\1`') # 角括弧をバッククォートへ

  # N'...'形式の文字列を'...'形式に変換
  insert_statement.gsub!(/N'((?:[^']|'')*)'/m) { |match| "'#{$1.gsub("''", "''")}'" }

  insert_statement.gsub!(/CAST\((0x[0-9A-Fa-f]+)\s+AS\s+DateTime\)/) do |match|
    begin
      hex_value = $1 # 正規表現のキャプチャ部分を取得
      datetime_str = hex_to_datetime(hex_value)
      "'#{datetime_str}'" # 日付形式に変換して返す
    rescue StandardError => e
      puts "エラー: #{e.message} (値: #{match})"
      "'0000-00-00 00:00:00'" # エラー時はデフォルト値を返す
    end
  end
  insert_statement
end

current_insert = ''

File.open(output_file, 'w') do |out_file|
  File.foreach(input_file) do |line|
    line = line.delete("\0") # 各行からNULLバイトを除去
    line.strip!

    # INSERT文の開始または継続を判定
    if line =~ /^INSERT\s/i
      current_insert = line.strip # INSERT文の開始
    else
      current_insert += " #{line.strip}" unless current_insert.empty? # 継続行を追加
    end

    # INSERT文が正しく閉じているか確認
    if current_insert =~ /\)\s*$/ && balanced?(current_insert)
      begin
        processed_insert = process_insert(current_insert)
        out_file.puts processed_insert
      rescue => e
        puts "エラー: 処理中のINSERT文が正しく処理できませんでした:\n#{current_insert}"
        puts "原因: #{e.message}"
      ensure
        current_insert = '' # バッファをクリア
      end
    end
  end
end

puts "置換が完了しました。結果は '#{output_file}' に保存されました。"

