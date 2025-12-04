class Mall::Amazon::UpdateService < Mall::UpdateService

  def call(master_parser, download_parser)
    # 商品選択肢の更新 なし
    # update_item_option(master_parser, download_parser)
    # 商品在庫数の更新
    update_item_stock(master_parser, download_parser)    
    # SKU在庫数の更新 なし
    # update_sku_stock(master_parser, download_parser)
  end

  # override
  # delivery_numの比較対象をleadtime_numに変更
  def need_update_stock?(master_parser, download_parser)
    return true if master_parser.stock.to_i != download_parser.stock.to_i
    return true if download_parser.leadtime_num.to_s.present? && master_parser.delivery_num.to_s != download_parser.leadtime_num.to_s
    return false
  end

end