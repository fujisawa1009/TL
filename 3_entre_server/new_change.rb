class InsertQueryConverter
    # INSERT文を変換するメインメソッド
    def self.convert_insert_query(sql, identity_column = nil)
      sql = sql.to_s.strip
      return "" if sql.empty?
  
      converted_sql = sql.dup
  
      # スキーマ名を削除
      converted_sql.sub!(/\[.*?\]\./, '')
  
      # テーブル名やカラム名をバッククォートで囲む ※値の中の括弧も変換してしまう
      converted_sql.gsub!(/\[(.*?)\]/) { "`#{$1}`" }
  
      # N'...' を '...' に変換 (改行も含むテキストはそのまま保持)
      converted_sql.gsub!(/N'((?:[^']|'')*)'/m) do |match|
        "'" + match[2..-2].gsub("\n", ' ') + "'"
      end
  
      # クエリの整形
      converted_sql.strip!
      converted_sql += ";" unless converted_sql.end_with?(";")
      converted_sql.chomp!
      converted_sql
    end
  
    # ファイルを読み込み、クエリを変換して別ファイルに出力
    def self.process_file(input_file, output_file, identity_column = nil)
      output = File.open(output_file, "w")
      buffer = ""
  
      File.foreach(input_file) do |line|
        stripped_line = line.strip
  
        # 不要な行をスキップ
        next if stripped_line.start_with?('GO') # "GO"で始まる行をスキップ
        next if stripped_line =~ /^print\s+'[^']*'/i # "print"で始まる行をスキップ
        next if stripped_line =~ /^\/\*+\s*.*?\s*\*+\/$/ # コメント行をスキップ (例: "/* ... */")
        next if stripped_line =~ /SET\s+IDENTITY_INSERT/i # SET IDENTITY_INSERT構文をスキップ
  
        # クエリをバッファに追加
        if buffer.match?(/;$/) || (stripped_line.match?(/^INSERT/i) && !buffer.empty?)
          converted_query = convert_insert_query(buffer, identity_column)
          output.puts(converted_query)
          buffer.clear
        end
  
        # 行を追加
        buffer << " " unless buffer.empty?
        buffer << stripped_line
      end
  
      # 残ったバッファを処理
      unless buffer.empty?
        converted_query = convert_insert_query(buffer, identity_column)
        output.puts(converted_query)
      end
  
      output.close
    end
  end
  
  # 入力ファイルと出力ファイルの指定
  input_file = 'input_system.sql'
  output_file = 'output_system.sql'
  identity_column = "ID"
  
  # 処理の実行
  InsertQueryConverter.process_file(input_file, output_file, identity_column)
  puts "クエリ変換が完了しました: #{output_file}"
  