class Mall::Roomclip::OutputService < Mall::OutputService

  # item.csv
  def get_item_stock_rows(item_parser, stock)
    [item_parser.url_code, salable?(item_parser) ? stock : 0]
  end
  
end