# 入力ファイルと出力ファイルのパスを指定
input_file = 'input_system.sql'  # 置換対象の入力ファイル
output_file = 'output_system.sql' # 置換後の出力ファイル

# ファイルを読み込み、内容を置換
File.open(output_file, 'w') do |out_file|
  File.foreach(input_file) do |line|

    line.strip! # 行の先頭と末尾の空白を削除

    # 不要な行を削除
    next if line.strip.start_with?('GO') # "GO"で始まる行をスキップ
    next if line.strip =~ /^print\s+'[^']*'/i # "print"で始まる行をスキップ
    next if line.strip =~ /^\/\*+\s*.*?\s*\*+\/$/ # コメント行をスキップ (例: "/* ... */")
    next if line.strip =~ /SET\s+IDENTITY_INSERT/i # SET IDENTITY_INSERT構文をスキップ

    # 1. INSERT文全体を取得（VALUES部分も含めて）
    if line =~ /INSERT \[(.*?)\]\.(.*?)\s\((.*?)\)\sVALUES\s\((.*)\)/mi #2024/12/2修正
      # 取得したSQL文全体を出力
      #pp "取得したINSERT文: #{ent}"

      # 2. (カラム値)の末尾にセミコロンを追加
      #pp "末尾変更前: #{line}"
      line.sub!(/\)\z/, ');')
      #pp"末尾変更後: #{line}"

      # 3. [entre].の部分を削除
      #pp "スキーマ名変更前: #{line}"
      line.sub!(/\[.*?\]\./, '')
      # pp "スキーマ名変更後: #{line}"

      # 4. [テーブル名] や [カラム名] の角括弧をバッククォートで囲む
      line.gsub!(/\[(.*?)\]/) { "`#{$1}`" }
      #pp "角括弧変更後: #{line}"

      # 6. (カラム値)部分のN'....'を'....'に置換
      line.gsub!(/N'((?:[^']|'')*)'/m, "'\\1'")
    end

    # 置換後の行を出力ファイルに書き込み
    out_file.puts line
  end
end

puts "置換が完了しました。結果は '#{output_file}' に保存されました。"
