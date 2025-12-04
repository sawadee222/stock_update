class Mall::Rakuten::OutputService < Mall::OutputService

  # item.csv
  def get_item_stock_rows(item_parser, stock)
    leadtime_master = @leadtime_master.detect{|leadtime| leadtime["rakuten_delivery_num"].to_s == item_parser.delivery_num.to_s}
    leadtime_name = leadtime_master.present? ? leadtime_master["lead_time_name"] : ""
    rows = [
      [item_parser.url_code, nil, nil, nil, nil],
      [item_parser.url_code, item_parser.url_code, stock, item_parser.delivery_num, leadtime_name]
    ]
  end

  # option.csv
  def get_item_option_rows(item_parser)
    rows = Array.new()
    option_key_hash = item_parser.option_array.group_by{|option_parser| option_parser.option_key}
    option_key_hash.each do |option_key, option_parser_array|
      next if option_parser_array.all?{|option_parser| option_parser.display_order == Parser::OptionParser::NO_DISPLAY_ORDER}
      row = [item_parser.url_code, "s", option_key].concat(option_parser_array.map{|option_parser| option_parser.option_value})
      row.fill(nil, row.size..103)
      rows.push(row)
    end

    rows = [[item_parser.url_code].concat(Array.new(103, nil))].concat(rows) if rows.size > 0

    return rows
  end

  # sku.csv
  def get_sku_stock_rows(item_parser)
    rows = [[item_parser.url_code, nil, nil, nil, nil]]
    item_parser.sku_array.each do |sku_parser|
      stock = sku_parser.stock.to_i > Constants::OUTPUT_LIMIT_STOCK ? Constants::OUTPUT_LIMIT_STOCK : sku_parser.stock.to_i
      leadtime_master = @leadtime_master.detect{|leadtime| leadtime["rakuten_delivery_num"].to_s == sku_parser.delivery_num.to_s}
      leadtime_name = leadtime_master.present? ? leadtime_master["lead_time_name"] : ""
      sku_code = sku_parser.sku_code || sku_parser.param_1 || sku_parser.url_code
      rows.push([sku_parser.url_code, sku_code, stock, sku_parser.delivery_num, leadtime_name])
    end

    return rows
  end

  
  # ------ 楽天 独自処理 --------#

  #
  # 選択肢
  # override
  def output_item_option_file(site_update_parsers, mall_key, site_key)
    super
    item_array = site_update_parsers.select{|item_parser| item_parser.option_update_flag == Parser::ItemParser::FLAG_UPDATE && item_parser.stock_type == Parser::ItemParser::STOCK_TYPE_ITEM}
    item_array.each do |item_parser|
      item_parser.option_array.each do |option_parser|
      end
    end
    delete_item_array = item_array.select{|item_parser|
      item_parser.option_array.any?{|option_parser| option_parser.update_flag == Parser::OptionParser::FLAG_DELETE}
    }
    # 削除用ファイル出力
    if delete_item_array.size > 0 then
      output_filepath = "#{@@upload_dir}#{File::Separator}#{mall_key}_#{site_key}_#{MallConstants::OPTION_DELETE_FILENAME}"
      Rails.logger.info("output file: #{output_filepath}")
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

  # option_delete.csv
  def get_output_option_delete_str(item_parser)
    output_str = ""
    copied_item_parser = item_parser.deep_dup
    option_key_hash = copied_item_parser.option_array.group_by{|option_parser| option_parser.option_key}
    option_key_hash.each do |option_key, option_parser_array|
      if option_parser_array.all?{|option_parser| option_parser.display_order == Parser::OptionParser::NO_DISPLAY_ORDER}
        output_str += CSV.generate_line([item_parser.url_code, "s", option_key], {col_sep: ","}).tosjis
      end
    end
    
    return output_str
  end

  # ------ 楽天 独自処理 end --------#
  
end