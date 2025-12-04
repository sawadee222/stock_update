class Mall::Dshopping::OutputService < Mall::OutputService

  # sku.csv
  def get_sku_stock_rows(item_parser)
    item_parser.sku_array.map{|sku_parser| [sku_parser.sku_code, salable?(item_parser) ? sku_parser.stock : 0]}
  end


  # ------ Dショッピング 独自処理 --------#

  # override
  def output_item_stock_file(site_update_parsers, mall_key, site_key)
    #
  end

  # ------ Dショッピング 独自処理 end --------#

end