# 入力ファイルと出力ファイルのパスを指定
input_file = 'input_system.sql'  # 置換対象の入力ファイル
output_file = 'output_system.sql' # 置換後の出力ファイル

# SQL文全体を構成するためのバッファ
sql_buffer = ""

File.open(output_file, 'w') do |out_file|
  File.foreach(input_file) do |line|
    line.strip! # 行の先頭と末尾の空白を削除
    next if line.empty? # 空行を無視

    # 不要な行を削除
    next if line.start_with?('GO') # "GO"で始まる行をスキップ
    next if line =~ /^print\s+'[^']*'/i # "print"で始まる行をスキップ
    next if line =~ /^\/\*+\s*.*?\s*\*+\/$/ # コメント行をスキップ
    next if line =~ /SET\s+IDENTITY_INSERT/i # SET IDENTITY_INSERT構文をスキップ

    # 行をバッファに追加
    sql_buffer << " " unless sql_buffer.empty?
    sql_buffer << line

    # 文末がセミコロンの場合、1つのSQL文として処理
    if sql_buffer.strip.end_with?(';')
      # INSERT文の正規表現にマッチ
      if sql_buffer =~ /INSERT\s+\[(.*?)\]\.(.*?)\s*\((.*?)\)\s*VALUES\s*\((.*)\)/mi
        # 1. スキーマ名を削除
        sql_buffer.sub!(/\[.*?\]\./, '')

        # 2. テーブル名やカラム名の角括弧をバッククォートに置換
        sql_buffer.gsub!(/\[(.*?)\]/, '`\1`')

        # 3. N'...'を'...'に置換
        sql_buffer.gsub!(/N'((?:[^']|'')*)'/m, "'\\1'")

        # 4. 文末にセミコロンを追加（必要なら）
        sql_buffer.sub!(/\)\z/, ');') unless sql_buffer.strip.end_with?(';')
      end

      # 処理結果を出力
      out_file.puts sql_buffer
      out_file.puts # ここで改行を追加
      sql_buffer = "" # バッファをクリア
    end
  end

  # 最後にバッファが残っていれば処理
  unless sql_buffer.empty?
    # INSERT文の正規表現にマッチ
    if sql_buffer =~ /INSERT\s+\[(.*?)\]\.(.*?)\s*\((.*?)\)\s*VALUES\s*\((.*)\)/mi
      # 1. スキーマ名を削除
      sql_buffer.sub!(/\[.*?\]\./, '')

      # 2. テーブル名やカラム名の角括弧をバッククォートに置換
      sql_buffer.gsub!(/\[(.*?)\]/, '`\1`')

      # 3. N'...'を'...'に置換
      sql_buffer.gsub!(/N'((?:[^']|'')*)'/m, "'\\1'")

      # 4. 文末にセミコロンを追加（必要なら）
      sql_buffer.sub!(/\)\z/, ');') unless sql_buffer.strip.end_with?(';')
    end

    # 処理結果を出力
    out_file.puts sql_buffer
  end
end

puts "置換が完了しました。結果は '#{output_file}' に保存されました。"
