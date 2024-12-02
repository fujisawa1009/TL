# 入力ファイルと出力ファイルのパス
input_file = 'input_system.sql'
output_file = 'output_system_non_newline.sql'

# 一時的にINSERT文を蓄積する変数
current_insert = ''

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
      puts "上記以外の場合: #{line}"
      next  
    end

    # 行がINSERT文の末尾か判定（例: ) が閉じている）
    if current_insert =~ /\)\s*$/
      # INSERT文を処理
      current_insert.gsub!(/\)\z/, ');')
      current_insert.sub!(/\[.*?\]\./, '') # スキーマ削除
      current_insert.gsub!(/\[(.*?)\]/, '`\\1`') # 角括弧をバッククォートへ
      current_insert.gsub!(/N'((?:[^']|'')*)'/m, "'\\1'") # N'...'を'...'へ

      # CAST(0x...) を日付に置換 まだ未修正
      current_insert.gsub!(/CAST\(0x[0-9A-Fa-f]+\s+AS\s+DateTime\)/) do |match|
        "'2004-03-01 00:00:00'" # 固定日付を返す
      end
      out_file.puts current_insert
      current_insert = '' # バッファをリセット
    else
      # INSERT文の途中の場合はそのまま出力
      # pp line
    end
  end
end

puts "置換が完了しました。結果は '#{output_file}' に保存されました。"