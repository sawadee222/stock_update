class Mall::Shopify::OutputService < Mall::OutputService

  # item.csv
  def get_item_stock_rows(item_parser, stock)
    stock = salable?(item_parser) ? stock : 0
    [item_parser.param_1, stock, item_parser.code]
  end

  # sku.csv
  def get_sku_stock_rows(item_parser)
    rows = Array.new()
    item_parser.sku_array.each do |sku_parser|
      stock = salable?(sku_parser) ? sku_parser.stock.to_i : 0
      row = [sku_parser.param_1, stock, sku_parser.url_code]
      rows.push(row)
    end

    return rows
  end


  # ------ Shopify 独自処理 --------#

  LEADTIME_EXCLUDE_SITE_CODE = [24, 136, 155]

  # override
  # リードタイムファイル出力処理追加
  def call(mall_updated_parsers, mall_master)
    super
    mall_master.master_sites.each do |site_master|
      site_update_parsers = mall_updated_parsers.select{|item_parser| item_parser.site_key == site_master.key}
      next if site_update_parsers.size == 0
      output_leadtime_file(site_update_parsers, mall_master.key, site_master.key)
    end
  end

  #
  # 商品単位のリードタイム
  #
  def output_leadtime_file(site_update_parsers, mall_key, site_key)
    # 対象外店舗
    item_array = site_update_parsers.select{|item_parser| !LEADTIME_EXCLUDE_SITE_CODE.include?(item_parser.site_code.to_i)}
    return unless item_array.size > 0

    # 納期文言空欄判定
    output_array = Array.new()
    item_array.each do |item_parser|
      if item_parser.stock_type == Parser::ItemParser::STOCK_TYPE_ITEM then
        output_array.push(item_parser) if get_leadtime_text(item_parser).present?
      else
        output_array.push(item_parser) if item_parser.sku_array.any?{|sku_parser| get_leadtime_text(sku_parser).present?}
      end
    end
    return unless output_array.size > 0

    output_filepath = "#{@@upload_dir}#{File::SEPARATOR}#{mall_key}_#{site_key}_#{MallConstants::LEADTIME_FILENAME}"
    Rails.logger.info("output file: #{output_filepath}")
    header_flag = File.exist?(output_filepath)
    mode = header_flag ? "a" : "w"
    # ファイル出力
    File.open(output_filepath, mode){|f|
      f.write(get_output_header_str(MallConstants::LEADTIME_FILENAME)) unless header_flag
      output_array.each do |item_parser|
        output_str = get_output_leadtime_str(item_parser)
        f.write output_str if output_str.to_s.present?
      end
    }
  end

  def get_leadtime_text(parser)
    leadtime_master = @leadtime_master.detect{|master| master['rakuten_delivery_num'].to_s == parser.delivery_num.to_s}
    return "" unless leadtime_master.present?
    leadtime_master['shopify_lead_time_name']
  end

  def get_output_leadtime_str(item_parser)
    product_id = nil
    variant_id = nil
    variant_metafield_leadtime_id = nil
    leadtime_text = get_leadtime_text(item_parser)
    json = JSON.parse(item_parser.json) if item_parser.json.present?
    if json.present? then
      product_id = json.has_key?('product_id') ? json['product_id'] : nil
      variant_id = json.has_key?('variant_id') ? json['variant_id'] : nil
      variant_metafield_leadtime_id = json.has_key?('variant_metafield_leadtime_id') ? json['variant_metafield_leadtime_id'] : nil
    end
    row = [product_id, variant_id, variant_metafield_leadtime_id, leadtime_text, item_parser.url_code]
    CSV.generate_line(row, {col_sep: ","}).tosjis
  end

  def salable?(parser)
    return true unless LEADTIME_EXCLUDE_SITE_CODE.include?(parser.site_code.to_i)
    super
  end

  # ------ Shopify 独自処理 end --------#

end