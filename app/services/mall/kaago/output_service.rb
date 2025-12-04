class Mall::Kaago::OutputService < Mall::OutputService

  # item.csv
  def get_item_stock_rows(item_parser, stock)
    stock = salable?(item_parser) ? stock : 0
    [item_parser.code, stock, item_parser.category_id, item_parser.leadtime_num]
  end


end