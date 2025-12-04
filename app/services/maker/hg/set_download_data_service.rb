class Maker::Hg::SetDownloadDataService < Maker::SetDownloadDataService
  
  HEADER_ROW_NUM = 3
  DELIVERY_NUM = 2
  LEADTIME_NUM = 3

  private

  def convert_values(row_hash)
    # 在庫状況変換
    case row_hash[Constants::STOCK]
    when "○", "〇" then
      stock = 100
    when "△" then
      stock = 100
    when "×" then
      stock = Utils::StringUtil.to_date_object(row_hash[Constants::DELIVERY_DATE]) ? 20 : 0
    else
      stock = 0
    end
    row_hash[Constants::STOCK] = stock

    # 納期管理番号
    row_hash[Constants::DELIVERY_NUM] = DELIVERY_NUM
    # リードタイム
    row_hash[Constants::LEADTIME_NUM] = LEADTIME_NUM

    return row_hash
  end
end