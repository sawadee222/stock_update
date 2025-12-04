class Mall::StoreeSaison::UpdateService < Mall::UpdateService

  def call(master_parser, download_parser)
    # 選択肢の更新
    # update_option(master_parser, download_parser)
    # 在庫数の更新
    update_stock(master_parser, download_parser)    
  end
  
end