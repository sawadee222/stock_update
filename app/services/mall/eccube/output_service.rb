class Mall::Eccube::OutputService < Mall::OutputService

  # item.csv
  def get_item_stock_rows(item_parser, stock)
    [item_parser.url_code, nil, nil, stock, item_parser.delivery_num]
  end

  # option.csv
  def get_item_option_rows(item_parser)
    rows = Array.new()
    item_parser.option_array.each do |option_parser|
      next if option_parser.display_order == Parser::OptionParser::NO_DISPLAY_ORDER
      rows.push([item_parser.url_code, option_parser.option_key, option_parser.option_value])
    end
    # オプションが空の場合はオプション削除データを設定
    rows.push([item_parser.url_code, nil, nil]) if rows.blank?

    return rows
  end

  # sku.csv
  def get_sku_stock_rows(item_parser)
    item_parser.sku_array.map{|sku_parser| [sku_parser.url_code, sku_parser.option_h, sku_parser.option_v, sku_parser.stock, sku_parser.delivery_num]}
  end

end