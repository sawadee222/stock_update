class Mall::OutputService < Mall::ApplicationService

  SALABLE_DELIVERY_NUMS = ["1", "2", "3", "4", "5", "11", "15", "17", "18", "19", "20", "22", "23", "24", "25", "70", "71", "72", "73", "74", "83"]

  def initialize()
    @leadtime_master = Utils::InternalUtil.get_leadtime_master()
  end

  def call(mall_updated_parsers, mall_master)
    mall_master.master_sites.each do |site_master|
      site_update_parsers = mall_updated_parsers.select{|item_parser| item_parser.site_key == site_master.key}
      next if site_update_parsers.size == 0

      FileUtils::mkdir_p(@@upload_dir) unless Dir.exist?(@@upload_dir)
      # 商品在庫数
      output_item_stock_file(site_update_parsers, mall_master.key, site_master.key)
      # 選択肢
      output_item_option_file(site_update_parsers, mall_master.key, site_master.key) if @@option_update_flag
      # SKU在庫数
      output_sku_stock_file(site_update_parsers, mall_master.key, site_master.key)
    end
  end

  private


  # ------------------------- 商品在庫数 --------------------------- #

  def output_item_stock_file(site_update_parsers, mall_key, site_key)
    item_array = site_update_parsers.select{|item_parser| item_parser.update_flag == Parser::ItemParser::FLAG_UPDATE && item_parser.stock_type == Parser::ItemParser::STOCK_TYPE_ITEM}
    return unless item_array.size > 0
    output_filepath = "#{@@upload_dir}#{File::SEPARATOR}#{mall_key}_#{site_key}_#{MallConstants::ITEM_STOCK_FILENAME}"
    Rails.logger.info("output file: #{output_filepath}")
    header_flag = File.exist?(output_filepath)
    mode = header_flag ? "a" : "w"
    # ファイル出力
    File.open(output_filepath, mode){|f|
      f.write(get_output_header_str(MallConstants::ITEM_STOCK_FILENAME)) unless header_flag
      item_array.each do |item_parser|
        output_str = get_output_item_stock_str(item_parser)
        f.write output_str if output_str.to_s.present?
      end
    }
  end

  #
  def get_output_item_stock_str(item_parser)
    output_str = ""
    stock = item_parser.stock.to_i > Constants::OUTPUT_LIMIT_STOCK ? Constants::OUTPUT_LIMIT_STOCK : item_parser.stock.to_i
    rows = get_item_stock_rows(item_parser, stock)
    rows = [rows] unless rows[0].is_a?(Array)
    rows.each do |row|
      output_str += CSV.generate_line(row, {col_sep: ","}).tosjis if row.present?
    end

    return output_str
  end

  #
  # overrideして各モールの出力形式に合わせる
  def get_item_stock_rows(item_parser, stock)
    #
  end



  # ------------------------- 選択肢 --------------------------- #

  def output_item_option_file(site_update_parsers, mall_key, site_key)
    item_array = site_update_parsers.select{|item_parser| item_parser.option_update_flag == Parser::ItemParser::FLAG_UPDATE && item_parser.stock_type == Parser::ItemParser::STOCK_TYPE_ITEM}
    return unless item_array.size > 0
    output_filepath = "#{@@upload_dir}#{File::SEPARATOR}#{mall_key}_#{site_key}_#{MallConstants::OPTION_FILENAME}"
    Rails.logger.info("output file: #{output_filepath}")
    header_flag = File.exist?(output_filepath)
    mode = header_flag ? "a" : "w"
    # ファイル出力
    File.open(output_filepath, mode){|f|
      f.write(get_output_header_str(MallConstants::OPTION_FILENAME)) unless header_flag
      item_array.each do |item_parser|
        output_str = get_output_option_str(item_parser)
        f.write output_str if output_str.to_s.present?
      end
    }
  end

  #
  def get_output_option_str(item_parser)
    output_str = ""
    copied_item_parser = item_parser.deep_dup
    copied_item_parser.option_array = item_parser.option_array.select{|option_parser| option_parser.display_order != Parser::OptionParser::NO_DISPLAY_ORDER}
    rows = get_item_option_rows(copied_item_parser)
    rows = [rows] unless rows[0].is_a?(Array)
    rows.each do |row|
      output_str += CSV.generate_line(row, {col_sep: ","}).tosjis if row.present?
    end

    return output_str
  end

  #
  # overrideして各モールの出力形式に合わせる
  def get_item_option_rows(item_parser)
    #
  end



  # ------------------------- SKU在庫数 --------------------------- #

  def output_sku_stock_file(site_update_parsers, mall_key, site_key)
    item_array = site_update_parsers.select{|item_parser| item_parser.sku_update_flag == Parser::ItemParser::FLAG_UPDATE}
    return unless item_array.size > 0
    output_filepath = "#{@@upload_dir}#{File::SEPARATOR}#{mall_key}_#{site_key}_#{MallConstants::SKU_STOCK_FILENAME}"
    Rails.logger.info("output file: #{output_filepath}")
    header_flag = File.exist?(output_filepath)
    mode = header_flag ? "a" : "w"
    # ファイル出力
    File.open(output_filepath, mode){|f|
      f.write(get_output_header_str(MallConstants::SKU_STOCK_FILENAME)) unless header_flag
      item_array.each do |item_parser|
        output_str = get_output_sku_stock_str(item_parser)
        f.write output_str if output_str.to_s.present?
      end
    }
  end

  #
  def get_output_sku_stock_str(item_parser)
    output_str = ""
    copied_item_parser = item_parser.deep_dup
    copied_item_parser.sku_array = item_parser.sku_array.select{|sku_parser| sku_parser.update_flag == Parser::SkuParser::FLAG_UPDATE}
    return output_str if copied_item_parser.sku_array.blank?

    copied_item_parser.sku_array.map{|sku_parser| sku_parser.stock = sku_parser.stock.to_i > Constants::OUTPUT_LIMIT_STOCK ? Constants::OUTPUT_LIMIT_STOCK : sku_parser.stock.to_i}
    rows = get_sku_stock_rows(copied_item_parser)
    rows = [rows] unless rows[0].is_a?(Array)
    rows.each do |row|
      output_str += CSV.generate_line(row, {col_sep: ","}).tosjis if row.present?
    end

    return output_str
  end

  #
  # 以下overrideして各モールの出力形式に合わせる
  def get_sku_stock_rows(item_parser)
    #
  end


  # ------------------------- 共通 --------------------------- #
  
  # 出力ファイルのヘッダーを取得
  def get_output_header_str(filename)
    CSV.generate_line("MallConstants::#{get_mall_name()}::HEADER".constantize[filename], {col_sep: ","}).tosjis
  end

  # モールによっては以下の納期判定でカートを閉じる
  def salable?(item_parser)
    return false if item_parser.stock.to_s == "0"
    return false if item_parser.delivery_num.to_s.present? && SALABLE_DELIVERY_NUMS.include?(item_parser.delivery_num.to_s)
    return false if item_parser.leadtime_num.to_s.present? && item_parser.leadtime_num.to_i >= 10
    date_obj = parse_date_obj(item_parser.delivery_date)
    if date_obj then
      return false if (date_obj - Date.today()).to_i > 5
    end
    return true
  end

  def parse_date_obj(date_format_str)
    Date.parse(date_format_str) rescue nil
  end

end