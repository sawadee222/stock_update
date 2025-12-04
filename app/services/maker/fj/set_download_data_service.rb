class Maker::Fj::SetDownloadDataService < Maker::SetDownloadDataService

  private

  # override
  def convert_values(row_hash)
    # 商品番号作成
    row_hash[Constants::CODE] = "#{@@prefix}-#{row_hash[Constants::CODE]}"
  end
  
end