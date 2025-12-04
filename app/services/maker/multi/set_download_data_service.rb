class Maker::Multi::SetDownloadDataService < Maker::SetDownloadDataService

  HEADER_CONFIG = {
    code: ["商品番号"],
    stock: ["在庫数"],
    option_key: ["項目名"],
    option_value: ["選択肢"],
    option_h: ["横軸選択肢"],
    option_v: ["縦軸選択肢"],
    delivery_num: ["楽天用納期管理番号", "納期管理番号"],
    leadtime_num: ["amazon用納期管理番号", "リードタイム"],
    delivery_date: ["amazon用入荷予定日", "入荷予定日"],
    supply_date: ["amazon用納品予定日", "納品予定日"]
  }
  REQUIRED_HEADRES = [
    :code,
    :stock,
    :option_key,
    :option_value,
    :option_h,
    :option_v
  ]


  def call()
    Rails.logger.debug("start:#{self.class.to_s}")

    laod_data_from_csv(get_download_file_path())

    Rails.logger.info("size(download_hash):#{@@download_hash.size}")

    Rails.logger.debug("end:#{self.class.to_s}")
  end

  private

  def laod_data_from_csv(download_file_path)
    File.open(download_file_path, "r:Shift_JIS:UTF-8", :undef => :replace) do |file|
      reader = CSV.new(file)

      header = reader.shift()
      header_index = get_header_index(header)

      reader.each do |row|
        set_download_hash_impl(row, header_index)
      end
    end
  end

  def get_header_index(header)
    header_index = Hash.new()
    index = nil
    
    HEADER_CONFIG.each do |key, values|
      values.each do |value|
        index = header.index(value)
        break if index.present?
      end
      if index.present? then
        header_index[key] = index
      elsif REQUIRED_HEADRES.include?(key) then
        raise SetStockException.new("在庫表のヘッダーの要素が見つかりません。(#{values.join(",")})")
      else
        Rails.logger.info("在庫表のヘッダーの要素を読み込みませんでした。(#{values.join(",")})")
      end
    end

    return header_index
  end

end