class Maker::Nd::SetDownloadDataService < Maker::SetDownloadDataService

  DELIVERY_NUM = 2
  LEADTIME_NUM = 3

  private

  def convert_values(row_hash)
    row_hash[Constants::OPTION_KEY] = "カラー"
    row_hash[Constants::OPTION_H_ID] = "カラー"
    # 納期管理番号
    row_hash[Constants::DELIVERY_NUM] = DELIVERY_NUM
    # リードタイム
    row_hash[Constants::LEADTIME_NUM] = LEADTIME_NUM

    return row_hash
  end
end