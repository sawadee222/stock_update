class Mall::Linemall::OutputService < Mall::OutputService

  # item.csv
  def get_item_stock_rows(item_parser, stock)
    [item_parser.url_code, stock]
  end
  
  # sku.csv
  def get_sku_stock_rows(item_parser)
    item_parser.sku_array.map{|sku_parser| [(sku_parser.param_1 || sku_parser.url_code), sku_parser.stock]}
  end


  # ------ LineMall 独自処理 --------#

  # override
  def output_item_option_file(site_update_parsers, mall_key, site_key)
    #
  end

  # ------ LineMall 独自処理 end --------#

end