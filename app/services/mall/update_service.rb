class Mall::UpdateService < Mall::ApplicationService

  def call(master_parser, download_parser)
    # 商品選択肢の更新
    update_item_option(master_parser, download_parser) if master_parser.stock_type == Parser::ItemParser::STOCK_TYPE_ITEM && @@option_update_flag
    # 商品在庫数の更新
    update_item_stock(master_parser, download_parser) if master_parser.stock_type == Parser::ItemParser::STOCK_TYPE_ITEM
    # SKU在庫数の更新
    update_sku_stock(master_parser, download_parser) if master_parser.stock_type == Parser::ItemParser::STOCK_TYPE_SKU
  end

  private

  #
  # 商品選択肢の更新
  #
  def update_item_option(master_parser, download_parser)
    # ラジボや"承諾"系や非表示を除外したオプション情報のみ抽出
    master_options = master_parser.option_array.select{|option_parser| option_parser.valid_option?}
    download_options = download_parser.option_array

    # 更新対象のオプションがない(オプションが一致する)場合はフラグの更新をしてスキップ
    unless need_update_options?(master_options, download_options) then
      master_parser.option_array.each do |option_parser|
        option_parser.update_flag = Parser::OptionParser::FLAG_NO_CHANGE
      end
      master_parser.option_update_flag = Parser::ItemParser::FLAG_NO_CHANGE
      download_parser.option_update_flag = Parser::ItemParser::FLAG_NO_CHANGE unless download_parser.option_update_flag == Parser::ItemParser::FLAG_UPDATE
      return 
    end

    order_count = 1
    master_options.each do |master_option|
      # ⓵マスタに存在する かつ 在庫情報に存在する → 再登録
      if download_options.any?{|dl_option| dl_option.option_value.to_s == master_option.option_value.to_s} then
        master_option.display_order = order_count
        master_option.update_flag = Parser::OptionParser::FLAG_DELETE_INSERT
        order_count += 1
      # ⓶マスタに存在する かつ 在庫情報に存在しない → 削除
      else
        master_option.display_order = Parser::OptionParser::NO_DISPLAY_ORDER
        master_option.update_flag = Parser::OptionParser::FLAG_DELETE
      end
    end
    download_options.each do |dl_option|
      # ⓷マスタに存在しない かつ 在庫情報に存在する → 追加
      if master_options.all?{|master_option| (master_option.option_value.to_s != dl_option.option_value.to_s)} then
        new_option = Parser::OptionParser.new(master_parser.item.pmg_sku)
        new_option.option_key = dl_option.option_key
        new_option.option_value = dl_option.option_value
        new_option.display_order = order_count
        new_option.update_flag = Parser::OptionParser::FLAG_INSERT
        master_parser.option_array.push(new_option)
        order_count += 1
      end
    end

    if master_parser.option_array.any?{|option_parser| option_parser.update_flag != Parser::OptionParser::FLAG_NO_UPDATE} then
      master_parser.option_update_flag = Parser::ItemParser::FLAG_UPDATE
      download_parser.option_update_flag = Parser::ItemParser::FLAG_UPDATE
    end

  end

  # 選択肢更新の有無
  def need_update_options?(master_options, download_options)
    # 比較用の文字列が一致するか
    mas_comparable_options = master_options.map{|master_option| master_option.compare_str}.sort!().join(",")
    dl_comparable_options = download_options.map{|download_option| download_option.compare_str}.sort!().join(",")
    return mas_comparable_options != dl_comparable_options
  end


  #
  # 商品在庫数の更新
  #
  def update_item_stock(master_parser, download_parser)
    update_stock(master_parser, download_parser)
  end

  #
  # SKU在庫数の更新
  #
  def update_sku_stock(master_parser, download_parser)
    master_parser.sku_array.each do |mas_sku_parser|
      download_parser.sku_array.each do |dl_sku_parser|
        update_stock(mas_sku_parser, dl_sku_parser) if sku_match?(mas_sku_parser, dl_sku_parser)
      end
    end

    if master_parser.sku_array.any?{|sku_parser| sku_parser.update_flag == Parser::SkuParser::FLAG_UPDATE} then
      master_parser.sku_update_flag = Parser::ItemParser::FLAG_UPDATE
      download_parser.sku_update_flag = Parser::ItemParser::FLAG_UPDATE
    end
    if master_parser.sku_array.all?{|sku_parser| sku_parser.update_flag == Parser::SkuParser::FLAG_NO_CHANGE} then
      master_parser.sku_update_flag = Parser::ItemParser::FLAG_NO_CHANGE
      download_parser.sku_update_flag = Parser::ItemParser::FLAG_NO_CHANGE unless download_parser.sku_update_flag == Parser::ItemParser::FLAG_UPDATE
    end
  end

  # バリエーションが一致するか
  def sku_match?(mas_sku_parser, dl_sku_parser)
    return false if mas_sku_parser.options_vh_value().blank?
    return false if mas_sku_parser.options_vh_value() != dl_sku_parser.options_vh_value()
    return true
  end

  # 在庫情報更新
  def update_stock(master_parser, download_parser)
    # amazonのlead-timeが未設定の場合は4とする（未設定で上げるとデフォルト値:2）
    download_parser.leadtime_num = 4 unless download_parser.leadtime_num.to_s.present?
    # 長期休暇設定をdownload_parserに反映
    long_vacation_setting(download_parser) if @@long_vacation_setting_flag
    # 休業日設定をdownload_parserに反映
    holiday_setting(download_parser)

    # 更新の必要ががない場合はフラグの更新をしてスキップ
    unless need_update_stock?(master_parser, download_parser) then
      master_parser.update_flag = Parser::SkuParser::FLAG_NO_CHANGE
      download_parser.update_flag = Parser::SkuParser::FLAG_NO_CHANGE unless download_parser.update_flag == Parser::SkuParser::FLAG_UPDATE
      return
    end
    master_parser.stock = download_parser.stock.to_i > Constants::UPDATE_LIMIT_STOCK ? Constants::UPDATE_LIMIT_STOCK : download_parser.stock.to_i
    master_parser.delivery_num = download_parser.delivery_num.to_s if download_parser.delivery_num.to_s.present?
    master_parser.leadtime_num = download_parser.leadtime_num.to_s if download_parser.leadtime_num.present?
    master_parser.update_flag = Parser::ItemParser::FLAG_UPDATE
    download_parser.update_flag = Parser::ItemParser::FLAG_UPDATE
  end

  # 長期休暇設定をdownload_parserに反映
  def long_vacation_setting(download_parser)
    download_parser.delivery_num.to_s = "55" if @@prefix == "ht"
  end

  # 休業日設定をdownload_parserに反映
  def holiday_setting(download_parser)
    begin
      @@holiday_setting ||= Utils::InternalUtil.get_holiday_setting()
      @@holiday_status_flag ||= Utils::InternalUtil.get_holiday_judgement().to_i
      return unless @@holiday_status_flag.to_i == 1
      # 休業日の場合、rakuten_delivery_num、amazon_delivery_numを更新
      @@holiday_setting.each do |type, holidays|
        case type.to_s
        when "delivery_number" then
          download_parser.delivery_num = holidays[download_parser.delivery_num.to_s].to_s if holidays.has_key?(download_parser.delivery_num.to_s)
        when "lead_time" then
          download_parser.leadtime_num = holidays[download_parser.leadtime_num.to_s].to_s if holidays.has_key?(download_parser.leadtime_num.to_s)
        end
      end
    rescue => ex
      Rails.logger.error("休業日設定の取得に失敗しました。")
      output_exception(ex)
    end
  end

  # 在庫数更新の有無
  def need_update_stock?(master_parser, download_parser)
    return true if master_parser.stock.to_s != download_parser.stock.to_s
    return true if master_parser.delivery_num.present? && download_parser.delivery_num.to_s.present? && master_parser.delivery_num.to_s != download_parser.delivery_num.to_s
    return false
  end
end
