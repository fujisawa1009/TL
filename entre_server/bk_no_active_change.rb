require 'date'

# 入力ファイルと出力ファイルのパス
input_file = 'input_system.sql'
output_file = 'output_system.sql'
current_insert = ''

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


File.open(output_file, 'w') do |out_file|
  File.foreach(input_file) do |line|
    line.strip! # 行の前後の空白を削除 chomp!だとだめ
    # 特定のコメント行や不必要な行をスキップ
    next if line.strip.start_with?('GO')
    next if line.strip.start_with?('USE')
    next if line.strip =~ /^print\s+'[^']*'/i
    next if line.strip =~ /^\/\*+.*\*+\/$/ # コメント行をスキップ (例: "/* ... */")
    next if line.strip =~ /SET\s+IDENTITY_INSERT/i # SET IDENTITY_INSERT構文をスキップ

    # INSERT文の開始または継続を判定
    # if line =~ /^INSERT\s/i
    #   current_insert += " #{line.strip}"
    # elsif !current_insert.empty?
    #   current_insert += " #{line.strip}"
    # else
    #   # INSERT文の途中でない場合はそのまま出力して次の行へ
    #   pp line
    #   next  
    # end

    # INSERT文の開始または継続を判定
    if line =~ /^INSERT\s/i
      current_insert = line.strip # INSERT文の開始
    else
      current_insert += " #{line.strip}" unless current_insert.empty? # 継続行を追加
    end

    # 行がINSERT文の末尾か判定（例: ) が閉じている）
    if current_insert =~ /\)\s*$/ 
      # INSERT文を処理
      current_insert.gsub!(/\)\z/, ');') # zは末尾の ) を ); に変換
      current_insert.sub!(/\[.*?\]\./, '') # スキーマ削除
      current_insert.gsub!(/(\[)([^\]]+)(\])(?=.*?values)/i, '`\\2`') # 角括弧をバッククォートへ
      current_insert.gsub!(/N'((?:[^']|'')*)'/m, "'\\1'") # N'...'を'...'へ

      # CAST(0x...) を日付形式に置換
      current_insert.gsub!(/CAST\((0x[0-9A-Fa-f]+)\s+AS\s+DateTime\)/) do |match|
        begin
          hex_value = $1 # 正規表現のキャプチャ部分を取得
          datetime_str = hex_to_datetime(hex_value)
          "'#{datetime_str}'" # 日付形式に変換して返す
        rescue StandardError => e
          puts "エラー: #{e.message} (値: #{match})"
          "'0000-00-00 00:00:00'" # エラー時はデフォルト値を返す
        end
      end

      out_file.puts current_insert
      # puts "変換後のSQL: #{current_insert}" if current_insert =~ /INSERT/i
      current_insert = '' # バッファをリセット
    end
  end
end

puts "置換が完了しました。結果は '#{output_file}' に保存されました。"
