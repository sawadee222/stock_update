class Mall::Yaichi::OutputService < Mall::OutputService

  # override
  def output_item_option_file(site_update_parsers, mall_key, site_key)
    #
  end

  def get_item_stock_rows(item_parser, stock)
    [item_parser.url_code, nil, stock, item_parser.delivery_num]
  end

  def get_sku_stock_rows(item_parser)
    item_parser.sku_array.map{|sku_parser| [sku_parser.url_code, sku_parser.param_1, sku_parser.stock, sku_parser.delivery_num]}
  end

end