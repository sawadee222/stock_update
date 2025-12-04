class Common::SetUpdateDataService < Common::ApplicationService

  def call()
    Rails.logger.debug("start:#{self.class.to_s}")
    begin
      service_hash = Hash.new()
      @@download_hash.each_value do |download_parser|
        # 英大文字/小文字で差分がある場合に対処
        code = download_parser.code.downcase
        # 商品番号が一致する商品の在庫情報を更新する
        next unless @@master_hash.has_key?(code)
        @@master_hash[code].each do |master_parser|

          # モールごとのデータ更新用クラスのインスタンスを作成
          mall_key = master_parser.mall_key
          unless service_hash.has_key?(mall_key) then
            update_service = "Mall::#{mall_key.camelize}::UpdateService".classify.constantize.new() rescue next
            service_hash.store(mall_key, update_service)              
          end

          # モールごとのデータ更新用クラスのインスタンスを呼び出し
          update_service = service_hash[mall_key]

          # モールごとのデータ更新用クラスを実行
          update_service.call(master_parser, download_parser)
        end
      end
      
      rebuild_master_hash()
      
      set_updated_parser()
      
      Rails.logger.info("更新対象の商品ページ数：#{@@updated_parsers.size}")
    rescue => ex
      output_exception(ex)
      raise SetStockException.new()
    end
    Rails.logger.debug("end:#{self.class.to_s}")
  end

  private

  # codeとバリエーションでの更新とsku_codeでの更新の被りを解消
  def rebuild_master_hash()
    # master_hashに追加するitem_parserを格納する配列
    provided_parser_array = Array.new()

    @@master_hash.each do |code, item_parser_array|      
      # 削除対象のitem_praserのIDを格納する配列
      delete_pmg_sku_ids = Array.new()

      item_parser_array.each do |item_parser|
        # sku_code照合で更新するitem_parserの場合は処理対象
        next unless (item_parser.item.is_a?(PmgSku) && item_parser.update_flag == Parser::ItemParser::FLAG_UPDATE)

        # sku_code照合で更新のitem_parserをsku_parserに変換
        new_sku_parser = item_parser.item.sku_parser
        new_sku_parser.update_flag = item_parser.update_flag

        # 同一SKUに対してバリエーションで照合しているitem_parserを取得
        target_item_parser = @@master_hash[new_sku_parser.sku.item_code].detect{|parser| parser.mall_key == new_sku_parser.mall_key && parser.site_key == new_sku_parser.site_key} rescue nil

        if target_item_parser.present? then
          # バリエーション照合のSKUをsku_code照合のSKUで置換
          replace_sku_parser(target_item_parser, new_sku_parser)
        else
          # master_hashに追加するitem_parserを作成
          provided_parser_array.push(provide_new_item_parser(new_sku_parser))
        end
        # 置換した/追加するので、item_parserを削除対象に追加
        delete_pmg_sku_ids.push(item_parser.item.id)
      end

      # 削除対象のitem_parserをitem_parser_arrayから削除
      item_parser_array.delete_if{|item_parser| delete_pmg_sku_ids.include?(item_parser.id)}
      # @@master_hash[code]のitem_parser_arrayが空なら削除
      @@master_hash.delete(code) if @@master_hash[code].blank?
    end

    # 追加対象のitem_parserをitem_parser_arrayに追加
    provided_parser_array.each do |provided_parser|
      # @@master_hashのキーにitme_codeが存在していなければ、格納用の空配列を作成しておく
      @@master_hash[provided_parser.code] = Array.new() unless @@master_hash.has_key?(provided_parser.code)
      @@master_hash[provided_parser.code].push(provided_parser)
    end
  end

  # バリエーション照合のSKUをsku_code照合のSKUで置換
  def replace_sku_parser(target_item_parser, new_sku_parser)
    target_item_parser.sku_array.delete_if{|sku_parser| sku_parser.sku_code == new_sku_parser.sku_code}
    target_item_parser.sku_array.push(new_sku_parser)
    target_item_parser.sku_update_flag = new_sku_parser.update_flag if target_item_parser.sku_update_flag == Parser::ItemParser::FLAG_NO_UPDATE
  end

  # 新しいsku_parserを所持するためのitem_parserを作成、sku_arrayにsku_parserを格納
  def provide_new_item_parser(new_sku_parser)
    new_item_parser = Parser::ItemParser.new({
      id: new_sku_parser.sku.item_id,
      code: new_sku_parser.sku.item_code,
      site_master_id: new_sku_parser.site_master_id,
      stock_type: Parser::ItemParser::STOCK_TYPE_SKU,
      url_code: new_sku_parser.url_code,
      mall_key: new_sku_parser.mall_key,
      site_key: new_sku_parser.site_key
    })
    new_item_parser.sku_update_flag = new_sku_parser.update_flag
    new_item_parser.sku_array.push(new_sku_parser)

    return new_item_parser
  end

  # 更新のあるitem_parserをクラス変数に格納
  def set_updated_parser()
    @@master_hash.each_value do |item_parser_array|
      item_parser_array.each do |item_parser|

        # ダウンロードしたデータに存在しない商品の在庫数を0に更新する
        update_parser_stock_zero(item_parser) if @@maker_config['absent_data_stock_zero']

        if item_parser.update_flag == Parser::ItemParser::FLAG_UPDATE ||\
          item_parser.option_update_flag == Parser::ItemParser::FLAG_UPDATE ||\
          item_parser.sku_update_flag == Parser::ItemParser::FLAG_UPDATE then

          @@updated_parsers.push(item_parser.clone)

        end
      end
    end
  end

  # ダウンロードしたデータに存在しない商品の在庫数を0に更新する
  def update_parser_stock_zero(item_parser)
    # 在庫数、選択肢、SKUにいずれもチェックが無ければ、在庫数0、選択肢削除、SKU在庫数0
    if item_parser.update_flag == Parser::ItemParser::FLAG_NO_UPDATE &&\
      item_parser.option_update_flag == Parser::ItemParser::FLAG_NO_UPDATE &&\
      item_parser.sku_update_flag == Parser::ItemParser::FLAG_NO_UPDATE then

      if item_parser.stock_type == Parser::ItemParser::STOCK_TYPE_ITEM && item_parser.stock.to_s != "0" then

        # 商品単位の在庫数を0
        item_parser.stock = 0
        item_parser.update_flag = Parser::ItemParser::FLAG_UPDATE

        # 選択肢を全削除
        if item_parser.has_valid_option? && @@option_update_flag then
          item_parser.option_array.select{|option_parser| option_parser.valid_option?}.each do |option_parser|
            option_parser.update_flag = Parser::OptionParser::FLAG_DELETE
            option_parser.display_order = Parser::OptionParser::NO_DISPLAY_ORDER
          end
          item_parser.option_update_flag = Parser::ItemParser::FLAG_UPDATE
        end

      # 全SKU在庫数を0
      elsif item_parser.sku_array.size > 0 then
        item_parser.sku_array.each do |sku_parser|
          if sku_parser.stock != 0 then
            sku_parser.stock = 0
            sku_parser.update_flag = Parser::SkuParser::FLAG_UPDATE
            item_parser.sku_update_flag = Parser::ItemParser::FLAG_UPDATE unless item_parser.sku_update_flag == Parser::ItemParser::FLAG_UPDATE
          end
        end
      end
      
    end
  end

end