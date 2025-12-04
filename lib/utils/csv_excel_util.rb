module Utils::CsvExcelUtil

  def self.get_csv_header(reader, header_config)
    reader.each do |row|
      diff = row & header_config.values
      if diff.size == header_config.size
        return row
      end
    end
    raise SetStockException.new("在庫表のヘッダー行が見つかりませんでした。")
  end

  def self.get_header_index(header, header_config)
    header_index = Hash.new()

    header_config.each do |key, value|
      index = header.index(value)
      if value.present? && index.present? then
        header_index[key.gsub(/header_/, "").to_sym] = index
      else
        raise SetStockException.new("在庫表のヘッダーの要素が見つかりません。(#{value})")
      end
    end
    
    return header_index
  end

  def self.open_spreadsheet(file_path)
    case File.extname(file_path)
    when ".xls" then
      Roo::Excel.new(file_path)
    when ".xlsx" then
      Roo::Excelx.new(file_path)
    else
      raise DownloadException.new("対応していない在庫表の拡張子です。: #{file_path}")
    end
  end
end