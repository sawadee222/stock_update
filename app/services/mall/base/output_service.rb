class Mall::Base::OutputService < Mall::OutputService

  # item.csv
  def get_item_stock_rows(item_parser, stock)
    [item_parser.url_code, stock, item_parser.code]
  end

end