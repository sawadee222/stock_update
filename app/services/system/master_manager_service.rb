class System::MasterManagerService < System::ApplicationService

  def initialize()
  end

  def fetch(code_array = [])
    code_array = get_code_array() if code_array.blank?
    items = get_master_items(code_array)
    skus = get_master_skus(code_array)
    Rails.logger.debug("DB records count  code:#{items.size}  sku_code:#{skus.size}")
    parser_hash = wrap_parser(items, skus)
    set_master_hash(parser_hash)
  end

  def update()
    update_stock_info()
    # update_option_info()
  end

  private

  # ------- fetch --------#

  # 更新対象となりうる品番を取得
  def get_code_array()
    code_array = Array.new()

    code_array.concat(PmgItem.select(:code).where('code LIKE ?', "#{@@prefix}-%").pluck(:code))
    code_array.concat(PmgSku.select(:sku_code).where('sku_code LIKE ?', "#{@@prefix}-%").pluck(:sku_code))
    code_array.concat(PmgSku.select(:url_code).where('sku_code LIKE ?', "#{@@prefix}-%").pluck(:url_code))
    code_array.sort!()
    code_array.uniq!()

    code_array
  end

  # codeでの更新対象のpmg_itemsレコードを取得
  def get_master_items(code_array)
    # pmg_items.codeに存在する品番のみ抽出
    item_code_array = PmgItem.select(:code).where(code: code_array).pluck(:code).uniq!
    # リレーション先も含めた商品情報レコードの取得
    items = PmgItem.joined_select(item_code_array)
  end

  # sku_codeでの更新対象のpmg_itemsレコードを取得
  def get_master_skus(code_array)
    # pmg_skus.sku_codeに存在する品番のみ抽出
    sku_code_array = PmgSku.select(:sku_code).where(sku_code: code_array).pluck(:sku_code).uniq!
    # リレーション先も含めたSKU情報レコードの取得
    skus = PmgSku.joined_select(sku_code_array)
  end

  def wrap_parser(items, skus)
    hash = Hash.new()
    items.each do |item|
      hash[item.id.to_s] = item.item_parser unless hash.has_key?(item.id.to_s) # 新規item_parserを登録
      hash[item.id.to_s].option_array.push(item.pmg_sku.option_parser) if item.option_value.present? # 既存のitem_parserにoption_parserを追加
      hash[item.id.to_s].sku_array.push(item.pmg_sku.sku_parser) if item.option_h.present? # 既存のitem_parserにsku_parserを追加
      # sku_codeがあれば、そのSKUでitem_parser作成
      hash["#{item.id}-#{item.sku_id}"] = item.pmg_sku.item_parser if (item.stock_type.to_s == "2" && item.sku_code.present?)
    end
    skus.each do |sku|
      # sku_codeがあるので、そのSKUでitem_parser作成
      hash["#{sku.item_id}-#{sku.id}"] = sku.item_parser unless hash.has_key?("#{sku.item_id}-#{sku.id}")
    end
    hash
  end

  def set_master_hash(parser_hash)
    parser_hash.each do |id, parser|
      code = parser.code.downcase
      @@master_hash[code] = Array.new() unless @@master_hash.has_key?(code)
      @@master_hash[code].push(parser)
    end
  end

  # ------- update --------#

  def update_stock_info()
    item_update_array = Array.new()
    sku_update_array = Array.new()
    option_update_array = Array.new()

    @@updated_parsers.each do |item_parser|
      Rails.logger.info(item_parser)
      if item_parser.stock_type == Parser::ItemParser::STOCK_TYPE_ITEM then
        item_update_array.push(item_parser.item) if item_parser.update_flag == Parser::ItemParser::FLAG_UPDATE
        option_update_array.concat(item_parser.option_array.map{|option_parser| option_parser.option})
      elsif item_parser.stock_type == Parser::ItemParser::STOCK_TYPE_SKU then
        sku_update_array.concat(item_parser.sku_array.map{|sku_parser| sku_parser.sku})
      end
    end

    PmgItem.import! item_update_array, on_duplicate_key_update: [:stock, :delivery_num, :delivery_date]
    PmgSku.import! option_update_array, on_duplicate_key_update: [:url_code, :options_type, :options_name, :options, :display_order,]
    PmgSku.import! sku_update_array, on_duplicate_key_update: [:stock, :delivery_num, :delivery_date]
  end

end