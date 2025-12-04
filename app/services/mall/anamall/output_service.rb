class Mall::Anamall::OutputService < Mall::OutputService
  
  def get_item_stock_rows(item_parser, stock)
    code = "0123-#{item_parser.code}"
    stock = salable?(item_parser) ? stock : 0
    [code, stock]
  end

  
  # ------ ANAモール 独自処理 --------#
  
  # override
  def output_item_option_file(site_update_parsers, mall_key, site_key)
    #
  end
  
  # ------ ANAモール 独自処理 end --------#

end