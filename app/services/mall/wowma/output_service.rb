class Mall::Wowma::OutputService < Mall::OutputService

  # item.csv
  def get_item_stock_rows(item_parser, stock)
    stock = item_parser.display_type.to_s == "1" ? stock : 0
    sale_status = stock.to_i > 0 ? 1 : 2
    ["U", item_parser.url_code, sale_status, stock, item_parser.delivery_num]
  end

  # option.csv
  def get_item_option_rows(item_parser)
    options_hash = item_parser.option_array.group_by{|option_parser| option_parser.option_key}
    row = ["U", item_parser.url_code].concat(options_hash.map{|key, parser_array| [key].concat(parser_array.map{|option_parser| option_parser.option_value.gsub(":","：")}).join(":")})
    row.fill("NULL", row.size..21)
  end

  # sku.csv
  def get_sku_stock_rows(item_parser)
    rows = Array.new()
    sale_status = item_parser.sku_array.any?{|sku_parser| sku_parser.stock.to_i > 0}
    item_parser.sku_array.each do |sku_parser|
      row = ["U", item_parser.url_code, "2", sale_status, sku_parser.option_h_id, sku_parser.option_v_id, sku_parser.stock, sku_parser.delivery_num]
      rows.push(row)
    end
    
    return rows
  end
end