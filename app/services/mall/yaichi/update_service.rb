class Mall::Yaichi::UpdateService < Mall::UpdateService

  def call(master_parser, download_parser)
    # 商品選択肢の更新 無し
    # update_item_option(master_parser, download_parser)
    # 商品在庫数の更新
    update_item_stock(master_parser, download_parser)
    # SKU在庫数の更新 無し
    # update_sku_stock(master_parser, download_parser)
  end
  
end