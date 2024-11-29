# 入力ファイルと出力ファイルのパスを指定
input_file = 'input.txt'  # 置換対象の入力ファイル
output_file = 'output.txt' # 置換後の出力ファイル

# ファイルを読み込み、内容を置換
File.open(output_file, 'w') do |out_file|
  File.foreach(input_file) do |line|
    # 正規表現による置換処理
    result = line.gsub(/INSERT\s+\[([^\]]+)\]\.\[([^\]]+)\]\s+\(\s*(.*?)\s*\)/) do
      table_schema = $1
      table_name = $2
      columns = $3.gsub(/\[([^\]]+)\]/, '`\1`') # カラム名の角括弧をバッククォートに置換
      "INSERT INTO `#{table_schema}`.`#{table_name}` (#{columns})"
    end
    # 置換後の結果を書き出し
    out_file.puts(result)
  end
end

puts "置換が完了しました。結果は '#{output_file}' に保存されました。"
