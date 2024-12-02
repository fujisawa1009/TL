# 入力ファイルと出力ファイルのパスを指定
input_file = 'input_system.sql'  # 置換対象の入力ファイル
output_file = 'output_system.sql' # 置換後の出力ファイル

# ファイルを読み込み、内容を置換
File.open(output_file, 'w') do |out_file|
  File.foreach(input_file) do |line|
    # 不要な行を削除
    next if line.strip.start_with?('GO') # "GO"で始まる行をスキップ
    next if line.strip =~ /^print\s+'[^']*'/i # "print"で始まる行をスキップ
    next if line.strip =~ /^\/\*+\s*.*?\s*\*+\/$/ # コメント行をスキップ (例: "/* ... */")
    next if line.strip =~ /SET\s+IDENTITY_INSERT/i # SET IDENTITY_INSERT構文をスキップ

    # N'...' 部分を一時的に置き換え、処理対象から外す
    n_quoted_strings = []
    line.gsub!( /N'([^']+)'/ ) do |match|
      n_quoted_strings << match
      "'__N_QUOTED_STRING__#{n_quoted_strings.size - 1}__'"
    end

    # 正規表現の置換処理
    result = line.gsub(/INSERT\s+\[[^\]]+\]\.\[([^\]]+)\]\s+\((.*?)\)/, 'INSERT `\1` (\2)') # INSERT文の置換
    result.gsub!(/\[([^\]]+)\]/, '`\1`') # カラム名の角括弧をバッククォートに置換

    # 'N' を削除し、改行やセミコロンを適切に処理
    result.gsub!(/'__N_QUOTED_STRING__\d+__'/) do |match|
      # n_quoted_stringsに戻して'を置換
      index = match[22..-3].to_i
      content = n_quoted_strings[index][2..-2] # 'N'と'を除去
      content.gsub!("\n", ' ')  # 改行をスペースに置換
      content.gsub!(';', ' ')   # セミコロンをスペースに置換
      "'#{content}'"
    end

    # 変換した N'...' 部分を戻す
    n_quoted_strings.each_with_index do |n_string, index|
      result.gsub!("'__N_QUOTED_STRING__#{index}__'", n_string)
    end

    # INSERT文が')'で終わっている場合にセミコロンを追加
    result.strip!
    result += ';' if result.end_with?(')')

    # 置換後の結果を書き出し
    out_file.puts(result)
  end
end

puts "置換が完了しました。結果は '#{output_file}' に保存されました。"
