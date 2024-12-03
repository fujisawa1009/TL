require 'date'

# 入力ファイルと出力ファイルのパス
input_file = 'input_system.sql'
output_file = 'output_system.sql'

# 一時的にINSERT文を蓄積する変数
current_insert = ''

def hex_to_datetime(hex_value)
  # 日数部分（最初の4バイト）
  days = hex_value[2, 8].to_i(16)

  # 秒数部分（次の4バイト）
  seconds = hex_value[10, 8].to_i(16) / 300.0

  # 基準日（1900-01-01）
  base_date = DateTime.new(1900, 1, 1)

  # 日数と秒数を加算してDATETIME型に変換
  datetime_value = base_date + days + Rational(seconds, 86400)

  # フォーマットを指定して出力
  datetime_value.strftime('%Y-%m-%dT%H:%M:%S')
end

File.open(output_file, 'w') do |out_file|
  File.foreach(input_file) do |line|
    line.strip!
    # 特定のコメント行や不必要な行をスキップ
    next if line.strip.start_with?('GO')
    next if line.strip =~ /^print\s+'[^']*'/i
    next if line.strip =~ /^\/\*+.*\*+\/$/ # コメント行をスキップ (例: "/* ... */")
    next if line.strip =~ /SET\s+IDENTITY_INSERT/i # SET IDENTITY_INSERT構文をスキップ

    # INSERT文の開始または継続を判定
    if line =~ /^INSERT\s/i
      current_insert += " #{line.strip}"
    elsif !current_insert.empty?
      current_insert += " #{line.strip}"
    else
      # INSERT文の途中でない場合はそのまま出力
      next  
    end

    # 行がINSERT文の末尾か判定（例: ) が閉じている）
    if current_insert =~ /\)\s*$/ 
      # INSERT文を処理
      current_insert.gsub!(/\)\z/, ');')
      current_insert.sub!(/\[.*?\]\./, '') # スキーマ削除
      current_insert.gsub!(/\[(.*?)\]/, '`\\1`') # 角括弧をバッククォートへ
      current_insert.gsub!(/N'((?:[^']|'')*)'/m, "'\\1'") # N'...'を'...'へ

      # CAST(0x...) を日付形式に置換
      current_insert.gsub!(/CAST\((0x[0-9A-Fa-f]+)\s+AS\s+DateTime\)/) do |match|
        hex_value = $1 # 正規表現のキャプチャ部分を取得
        datetime_str = hex_to_datetime(hex_value)
        "'#{datetime_str}'" # 日付形式に変換して返す
      end

      out_file.puts current_insert
      current_insert = '' # バッファをリセット
    end
  end
end

puts "置換が完了しました。結果は '#{output_file}' に保存されました。"
