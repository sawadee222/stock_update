class Mall::Shopify::UpdateService < Mall::UpdateService

  def call(master_parser, download_parser)
    # 選択肢の更新 無し
    # update_option(master_parser, download_parser)
    # 在庫数の更新
    update_stock(master_parser, download_parser) if master_parser.stock_type == Parser::ItemParser::STOCK_TYPE_ITEM
    # SKU在庫数の更新
    update_sku_stock(master_parser, download_parser) if master_parser.stock_type == Parser::ItemParser::STOCK_TYPE_SKU
  end
  
end