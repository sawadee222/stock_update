class Mall::Qoo10::OutputService < Mall::OutputService

  # item.csv
  def get_item_stock_rows(item_parser, stock)
    stock = get_item_stock(item_parser, stock)
    [item_parser.url_code, item_parser.code, stock]
  end

  # option.csv
  def get_item_option_rows(item_parser)
    [item_parser.url_code, item_parser.code, get_option_info(item_parser)]
  end

  # sku.csv
  def get_sku_stock_rows(item_parser)
    rows = Array.new()
    item_parser.sku_array.each do |sku_parser|
      stock = get_sku_stock(sku_parser)
      price = sku_parser.param_2.present? ? sku_parser.param_2 : "0.00"
      if sku_parser.sku_code.present? then
        seller_code = ""
        option_name = ""
        option_value = ""
        option_code = sku_parser.sku_code
      else
        seller_code = item_parser.code
        option_name = [sku_parser.option_h_id, sku_parser.option_v_id].reject(&:blank?).join("||*")
        option_value = [sku_parser.option_h, sku_parser.option_v].reject(&:blank?).join("||*")
        option_code = ""
      end
      row = [sku_parser.url_code, seller_code, option_name, option_value, option_code, price, stock]
      rows.push(row)
    end
    return rows
  end


  # ------ Qoo10 独自処理 --------#

  #
  def get_item_stock(item_parser, stock)
    if item_parser.stock_type == "1" then
      # 有効なOptionParserがあるが、Option Infoが空の場合は納期が先のため在庫数を0に設定
      return (!salable?(item_parser) || (item_parser.has_valid_option? && get_option_info(item_parser).blank?)) ? 0 : stock
    elsif item_parser.stock_type == "2" then
      return item_parser.sku_array.sum{|sku_parser| get_sku_stock(sku_parser)}
    else
      return 0
    end
  end

  #
  def get_option_info(item_parser)
    option_array = Array.new()
    item_parser.option_array.each do |option_parser|
      next if option_parser.display_order == Parser::OptionParser::NO_DISPLAY_ORDER
      option_array.push(get_joined_option_str(option_parser))
    end
    option_array.reject(&:blank?).join("$$")
  end

  #
  def get_joined_option_str(option_parser)
    return "" if (option_parser.option_key.include?("入荷") || option_parser.option_value =~ /[0-9]月/)
    option_price = option_parser.param_2.present? ? option_parser.param_2 : "0.00"
    [option_parser.option_key, option_parser.option_value, option_price, option_parser.sku_code].join("||*")
  end

  #
  def get_sku_stock(sku_parser)
    salable?(sku_parser) ? (sku_parser.stock.to_i > 1000 ? 1000 : sku_parser.stock.to_i) : 0
  end

  # ------ Qoo10 独自処理 end --------#
  
end