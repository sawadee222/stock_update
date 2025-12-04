class Mall::Giftmall::OutputService < Mall::OutputService

  # item.csv
  def get_item_stock_rows(item_parser, stock)
    [item_parser.param_1, stock] 
  end
  
  # option.csv
  def get_item_option_rows(item_parser)
    #
  end

  # sku.csv
  def get_sku_stock_rows(item_parser)
    item_parser.sku_array.map{|sku_parser| [sku_parser.param_1, sku_parser.stock]}
  end

end