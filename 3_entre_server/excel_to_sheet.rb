# Excelファイルを読み込み、各シートをCSVファイルに保存するスクリプト
# 事前にgem install rooを実行しておくこと

require 'roo'
require 'csv'

def excel_to_csv(file_path, output_dir)
  # Excelファイルを読み込む
  workbook = Roo::Spreadsheet.open(file_path)

  # 出力先ディレクトリを作成
  Dir.mkdir(output_dir) unless Dir.exist?(output_dir)

  # 各シートを処理
  workbook.sheets.each do |sheet_name|
    # シートを選択
    workbook.default_sheet = sheet_name

    # CSVファイルのパスを設定
    csv_file_path = File.join(output_dir, "#{sheet_name}.csv")

    # CSVファイルに書き込み
    CSV.open(csv_file_path, 'w') do |csv|
      workbook.each_row_streaming do |row|
        csv << row.map(&:value)
      end
    end

    puts "シート '#{sheet_name}' を保存しました: #{csv_file_path}"
  end
end

# 使用例
excel_file_path = 'example.xlsx'      # 読み込むExcelファイルのパス
output_directory = 'output_csv'      # 保存するディレクトリ名

excel_to_csv(excel_file_path, output_directory)
