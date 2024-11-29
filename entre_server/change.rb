# 入力ファイルと出力ファイルのパスを指定
input_file = 'input.txt'  # 置換対象の入力ファイル
output_file = 'output.txt' # 置換後の出力ファイル

# ファイルを読み込み、内容を置換
File.open(output_file, 'w') do |out_file|
  File.foreach(input_file) do |line|
    # SET IDENTITY_INSERT構文を削除
    next if line =~ /SET\s+IDENTITY_INSERT/i

    # INSERT文の形式を置換 (スキーマ名を削除してテーブル名のみを残す)
    result = line.gsub(/INSERT\s+\[[^\]]+\]\.\[([^\]]+)\]/, 'INSERT INTO `\1`')

    # Unicode文字列 (N'...') をシングルクォート形式に置換
    result.gsub!(/N'([^']*)'/, "'\\1'")

    # CAST(0x...) を '2004-03-01 00:00:00' 形式に置換
    result.gsub!(/CAST\(0x[0-9A-Fa-f]+\s+AS\s+DateTime\)/, "'2004-03-01 00:00:00'")

    # 置換後の結果を書き出し
    out_file.puts(result)
  end
end

puts "置換が完了しました。結果は '#{output_file}' に保存されました。"
