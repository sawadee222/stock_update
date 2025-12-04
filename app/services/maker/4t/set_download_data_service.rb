class Maker::At::SetDownloadDataService < Maker::SetDownloadDataService

  DELIVERY_NUM = 31
  LEADTIME_NUM = 31

  private

  def laod_data_from_csv(download_file_path)
    for i in 1..13 do
      @@maker_config.store("header_warehouse#{i}", "利用可能在庫数#{i}")
    end
    super
  end

  def convert_values(row_hash)
    # 商品番号
    row_hash[Constants::CODE] = "#{@@prefix}-#{row_hash[Constants::CODE]}"
    # 在庫数
    row_hash[Constants::STOCK] = row_hash.select{|key, val| key.include?("warehouse")}.sum.to_i
    # 納期管理番号
    row_hash[Constants::DELIVERY_NUM] = DELIVERY_NUM
    # リードタイム
    row_hash[Constants::LEADTIME_NUM] = LEADTIME_NUM

    return row_hash
  end

end