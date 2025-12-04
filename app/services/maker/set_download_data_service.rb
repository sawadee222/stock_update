class Maker::SetDownloadDataService < Maker::ApplicationService

  HEADER_ROW_NUM = 1

  LINKING_MAPPING = {
    code: "gp_code",
    sku_code: "sku_code",
    option_key: "option_name_1",
    option_value: "gp_option_1",
    option_h: "gp_option_1",
    option_h_id: "option_name_1",
    option_v: "gp_option_2",
    option_v_id: "option_name_2",
  }

  def call()
    Rails.logger.debug("start:#{self.class.to_s}")

    # Web紐づけマスタ取得
    @linking_master = @@maker_config['web_linking'] ? Utils::InternalUtil.get_linking_master(@@prefix) : {}

    # 在庫データを読込
    case @@maker_config['format']
    when Constants::FILE_EXT_CSV then
      laod_data_from_csv(get_download_file_path())
    when Constants::FILE_EXT_EXCEL then
      laod_data_from_excel(get_download_file_path())
    end
    
    Rails.logger.info("size(download_hash):#{@@download_hash.size}")

    Rails.logger.debug("end:#{self.class.to_s}")
  end

  private

  #
  # 在庫データファイルのパスを取得
  #
  def get_download_file_path()
    file_preg = "*#{@@maker_config['filekey']}*.#{@@maker_config['format'] == Constants::FILE_EXT_EXCEL ? 'xls*' : 'csv'}"
    download_file_array = Dir.glob(@@download_dir + File::SEPARATOR + file_preg)

    raise DownloadException.new("所定のフォルダに在庫表が見つかりませんでした。(検索条件：#{file_preg})") if download_file_array.blank?
    raise DownloadException.new("所定のフォルダに在庫表が複数見つかりました。") if download_file_array.size > 1

    download_file_array[0].to_s
  end

  #
  # CSVから在庫データを読込
  #
  def laod_data_from_csv(download_file_path)
    File.open(download_file_path, "r:Shift_JIS:UTF-8", :undef => :replace) do |file|

      reader = CSV.new(file)
      header_config = @@maker_config.select{|key, value| key.include?('header_') && value.present?}

      header = Utils::CsvExcelUtil.get_csv_header(reader, header_config)
      header_index = Utils::CsvExcelUtil.get_header_index(header, header_config)

      reader.each do |row|
        set_download_hash_impl(row, header_index)
      end

    end
  end


  #
  # Excelから在庫データを読込
  #
  def laod_data_from_excel(download_file_path)
    sheet = Utils::CsvExcelUtil.open_spreadsheet(download_file_path)
    header_config = @@maker_config.select{|key, value| key.include?('header_') && value.present?}
    header_row_num = self.class::HEADER_ROW_NUM
    header = sheet.row(header_row_num)
    header_index = Utils::CsvExcelUtil.get_header_index(header, header_config)

    (header_row_num + 1 .. sheet.last_row).each do |i|
      row = sheet.row(i)
      set_download_hash_impl(row, header_index)
    end
  end

  #
  # 在庫データをdownload_hashに格納
  #
  def set_download_hash_impl(row, header_index)
    begin
      # code, sku_codeが両方無ければスキップ
      return if (row[header_index[Constants::CODE]].blank? && row[header_index[Constants::SKU_CODE]].blank?)
      
      # Hashに行の値を格納
      row_hash = Hash.new()
      header_index.each do |col, index|
        row_hash.store(col.to_sym, delete_space(row[header_index[col]].to_s))
      end
      
      # Web紐づけマスタの情報があれば変換
      if @@maker_config['web_linking'] then
        alt_row_hash = web_linking_convert(row_hash)
        unless alt_row_hash.present? then
          return
        end
        row_hash = alt_row_hash
      end

      # 変換する必要がある場合は、各メーカーでオーバーライドして使用
      row_hash = convert_values(row_hash)

      row_hash = apply_delivery_date(row_hash) if row_hash[Constants::DELIVERY_DATE].present?

      # Rails.logger.debug(row_hash) # ここの確認だけでOK

      parse_by_gp_code(row_hash)
      
      parse_by_sku_code(row_hash)

    rescue => ex
      Rails.logger.info(ex.message)
    end
  end

  # 納期情報を適用
  def apply_delivery_date(row_hash)
    # 入荷予定日取得
    delivery_date = Utils::StringUtil.to_date_object(row_hash[Constants::DELIVERY_DATE])
    unless delivery_date.present? then
      # Rails.logger.info("入荷予定変換不可#{row_hash[Constants::CODE]}(#{row_hash[Constants::DELIVERY_DATE]})")
      return row_hash
    end

    # 入荷予定日変換
    row_hash[Constants::DELIVERY_DATE] = delivery_date

    # 納期管理番号変換
    row_hash[Constants::DELIVERY_NUM] = Utils::StringUtil.date_to_delivery_num(delivery_date)

    # 納期文言追加
    deliver_str = Utils::StringUtil.date_to_delivery_string(delivery_date)
    if row_hash[Constants::OPTION_VALUE].present? then
      # 選択肢がある場合は選択肢の後ろに付加
      row_hash[Constants::OPTION_VALUE] = "#{row_hash[Constants::OPTION_VALUE.to_sym]}/#{deliver_str}"
    else
      # 選択肢がない場合は入荷予定の選択肢を作成
      row_hash[Constants::OPTION_KEY] = "入荷予定"
      row_hash[Constants::OPTION_VALUE] = deliver_str
    end

    return row_hash
  end

  #
  # 選択肢照合での更新データ作成
  #
  def parse_by_gp_code(row_hash)
    return if row_hash[Constants::CODE].blank?
    # item_parser作成/読込
    item_parser = @@download_hash.has_key?(row_hash[Constants::CODE]) ? @@download_hash[row_hash[Constants::CODE]] : Parser::ItemParser.new(row_hash)
    # option_parser作成
    if row_hash[Constants::STOCK].to_i > 0 && row_hash[Constants::OPTION_VALUE].present? then
      option_parser = Parser::OptionParser.new(row_hash)
      item_parser.stock = row_hash[Constants::STOCK] if item_parser.stock.to_i < row_hash[Constants::STOCK].to_i
      item_parser.option_array.push(option_parser)
    end
    # sku_parser作成
    if row_hash[Constants::OPTION_H].present? then
      sku_parser = Parser::SkuParser.new(row_hash)
      item_parser.sku_array.push(sku_parser)
    end
    @@download_hash.store(row_hash[Constants::CODE], item_parser)
  end

  #
  # sku_code照合での更新データ作成
  #
  def parse_by_sku_code(row_hash)
    return if row_hash[Constants::SKU_CODE].blank?
    clone_hash = row_hash.clone()
    clone_hash[Constants::CODE] = row_hash[Constants::SKU_CODE]
    item_parser = Parser::ItemParser.new(clone_hash)
    if @@download_hash.has_key?(clone_hash[Constants::CODE]) then
      Rails.logger.info("ダウンロードデータ内で個別品番が重複しています。：#{clone_hash[Constants::CODE]}")
    else
      @@download_hash.store(clone_hash[Constants::CODE], item_parser)
    end
  end

  # Web紐づけマスタ変換
  def web_linking_convert(row_hash)
    alt_row_hash = Hash.new()
    linking_master = @linking_master.detect{|link| link['code'].to_s.downcase == row_hash[Constants::CODE].to_s.downcase}
    return unless linking_master.present?
    LINKING_MAPPING.each do |row_hash_key, linking_key|
      alt_row_hash.store(row_hash_key, delete_space(linking_master[linking_key].to_s))
    end
    row_hash.each do |key, value|
      alt_row_hash.store(key, value) unless alt_row_hash.has_key?(key)
    end

    alt_row_hash
  end

  # 変換する必要がある場合は、各メーカーでオーバーライドして使用
  def convert_values(row_hash)
    row_hash
  end

end