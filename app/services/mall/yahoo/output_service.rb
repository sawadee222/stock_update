class Mall::Yahoo::OutputService < Mall::OutputService

  # item.csv
  def get_item_stock_rows(item_parser, stock)
    [item_parser.url_code, nil, stock]
  end

  # option.csv
  def get_item_option_rows(item_parser)
    rows = Array.new()
    item_parser.option_array.each do |option_parser|
      next if option_parser.display_order == Parser::OptionParser::NO_DISPLAY_ORDER
      row = Array.new(MallConstants::Yahoo::HEADER[MallConstants::OPTION_FILENAME].size)
      row[0] = item_parser.url_code         # code
      row[3] = option_parser.option_key     # option-name-1
      row[4] = option_parser.option_value   # option-value-1
      row[5] = option_parser.param_2        # spec-id-1
      row[6] = option_parser.param_3        # spec-value-id-1
      rows.push(row)
    end
    # 出力する更新ファイルは、ラジボ、プルダウンを一斉に更新するので、ラジボも出力する←本当？
    item_parser.sku_array.each do |sku_parser|
      row = Array.new(MallConstants::Yahoo::HEADER[MallConstants::OPTION_FILENAME].size)
      row[0] = item_parser.url_code         # code
      row[1] = sku_parser.sku_code          # sub-code
      row[3] = sku_parser.option_h_id       # option-name-1
      row[4] = sku_parser.option_h          # option-value-1
      row[7] = sku_parser.option_v_id       # option-name-2
      row[8] = sku_parser.option_v          # option-value-2
      leadtime_master = @leadtime_master.select{|leadtime| leadtime["rakuten_delivery_num"] == sku_parser.delivery_num}
      leadtime_num = leadtime_master.present? ? leadtime_master["yahoo_delivery_num"] : ""      
      row[12] = leadtime_num               # lead-time-instock
      row[14] = sku_parser.param_1          # sub-code-img1
      rows.push(row)
    end
    return rows
  end

  # sku.csv
  def get_sku_stock_rows(item_parser)
    item_parser.sku_array.map{|sku_parser| [item_parser.url_code, sku_parser.sku_code, sku_parser.stock]}
  end


  # ------ Yahoo 独自処理 --------#

  # override
  # リードタイムファイル出力処理追加
  def call(mall_updated_parsers, mall_master)
    super
    mall_master.master_sites.each do |site_master|
      site_update_parsers = mall_updated_parsers.select{|item_parser| item_parser.site_key == site_master.key}
      next if site_update_parsers.size == 0
      output_leadtime_file(site_update_parsers, mall_master.key, site_master.key)
    end
  end

  #
  # 商品単位のリードタイム
  #
  def output_leadtime_file(site_update_parsers, mall_key, site_key)
    item_array = site_update_parsers.select{|item_parser| (item_parser.update_flag == Parser::ItemParser::FLAG_UPDATE && item_parser.delivery_num.present?)}
    return unless item_array.size > 0
    output_filepath = "#{@@upload_dir}#{File::SEPARATOR}#{mall_key}_#{site_key}_#{MallConstants::LEADTIME_FILENAME}"
    Rails.logger.info("output file: #{output_filepath}")
    header_flag = File.exist?(output_filepath)
    mode = header_flag ? "a" : "w"
    # ファイル出力
    File.open(output_filepath, mode){|f|
      f.write(get_output_header_str(MallConstants::LEADTIME_FILENAME)) unless header_flag
      item_array.each do |item_parser|
        output_str = get_output_leadtime_str(item_parser)
        f.write output_str if output_str.to_s.present?
      end
    }
  end

  # 
  def get_output_leadtime_str(item_parser)
    leadtime_master = @leadtime_master.detect{|leadtime| leadtime["rakuten_delivery_num".to_s] == item_parser.delivery_num.to_s}
    leadtime_num = leadtime_master.present? ? leadtime_master["yahoo_delivery_num"] : ""
    CSV.generate_line([item_parser.url_code, leadtime_num], {col_sep: ","}).tosjis
  end

  #
  # override
  # 選択肢削除用ファイル出力処理追加
  def output_item_option_file(site_update_parsers, mall_key, site_key)
    super
    item_array = site_update_parsers.select{|item_parser| item_parser.option_update_flag == Parser::ItemParser::FLAG_UPDATE}
    delete_item_array = item_array.select{|item_parser| item_parser.option_array.all?{|option_parser| option_parser.update_flag == Parser::OptionParser::FLAG_DELETE}}
    # 削除用ファイル出力
    if delete_item_array.size > 0 then
      output_filepath = @@upload_dir + File::Separator + mall_key.to_s + "_" + site_key.to_s + "_" + MallConstants::OPTION_DELETE_FILENAME
      header_flag = File.exist?(output_filepath)
      mode = header_flag ? "a" : "w"
      # ファイル出力
      File.open(output_filepath, mode) {|f|
        f.write(get_output_header_str(MallConstants::OPTION_DELETE_FILENAME)) unless header_flag
        delete_item_array.each do |item_parser|
          output_str = get_output_option_delete_str(item_parser)
          f.write(output_str) if output_str.to_s.present?
        end
      }
    end
  end

  def get_output_option_delete_str(item_parser)
    output_str = ""
    option_key_array = item_parser.option_array.group_by{|option_parser| option_parser.option_key}
    option_key_array.each do |option_key, option_parser_array|
      if option_parser_array.all?{|option_parser| option_parser.display_order == Parser::OptionParser::NO_DISPLAY_ORDER}
      output_str += CSV.generate_line([item_parser.url_code, nil], {col_sep: ","}).tosjis
      end
    end
    return output_str
  end

  # ------ Yahoo 独自処理 end --------#

end