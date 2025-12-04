class Mall::StoreeSaison::OutputService < Mall::OutputService
  
  # item.csv
  def get_item_stock_rows(item_parser, stock)
    stock = salable?(item_parser) ? stock : 0
    [item_parser.url_code, stock]
  end

end