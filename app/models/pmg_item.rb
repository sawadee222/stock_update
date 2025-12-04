class PmgItem < ApplicationRecord

  belongs_to :master_site, foreign_key: :site_master_id
  
  validates :code, presence: true
  validates :url_code, presence: true
  validates :site_master_id, presence: true
  validates :stock_type, presence: true

  attribute :id
  attribute :code
  attribute :url_code
  attribute :site_master_id
  attribute :site_code
  attribute :name
  attribute :name_2
  attribute :price
  attribute :sale_price
  attribute :category_id
  attribute :display_type
  attribute :stock_type
  attribute :i_param_1
  attribute :i_param_2
  attribute :i_param_3
  attribute :json
  attribute :stock
  attribute :delivery_num
  attribute :delivery_date
  attribute :site_key
  attribute :mall_key
  attribute :sku_id
  attribute :sku_code
  attribute :option_type
  attribute :option_key
  attribute :option_value
  attribute :display_order
  attribute :option_h
  attribute :option_h_id
  attribute :option_v
  attribute :option_v_id
  attribute :s_param_1
  attribute :s_param_2
  attribute :s_param_3
  attribute :s_stock
  attribute :s_delivery_num
  attribute :s_delivery_date
 # 以降DBに無し（在庫表にあり）
  attribute :leadtime_num
  attribute :supply_date

  attr_accessor :item_parser

  SKU_ATTR_MAPPING = {
    "sku_id" => :id,
    "sku_code" => :code,
    "url_code" => :url_code,
    "site_master_id" => :site_master_id,
    "site_code" => :site_code,
    "option_type" => :option_type,
    "option_key" => :option_key,
    "option_value" => :option_value,
    "display_order" => :display_order,
    "option_h" => :option_h,
    "option_h_id" => :option_h_id,
    "option_v" => :option_v,
    "option_v_id" => :option_v_id,
    "s_param_1" => :s_param_1,
    "s_param_2" => :s_param_2,
    "s_param_3" => :s_param_3,
    "s_stock" => :stock,
    "s_delivery_num" => :delivery_num,
    "s_delivery_date" => :delivery_date,
    "site_key" => :site_key,
    "mall_key" => :mall_key,
    "id" => :item_id,
    "code" => :item_code,
    "i_param_1" => :i_param_1,
    "i_param_2" => :i_param_2,
    "i_param_3" => :i_param_3,
  }


  def item_parser()
    @item_parser = Parser::ItemParser.new(self)
  end

  # PmgSkuに変換
  def pmg_sku()
    PmgSku.new(sku_attr_hash())
  end

  def sku_attr_hash()
    attr_hash = Hash.new()
    self.attributes.each do |key, value|
      attr_hash.store(SKU_ATTR_MAPPING[key], value) if SKU_ATTR_MAPPING.has_key?(key)
    end

    return attr_hash
  end

  # pmg_items.codeで検索してリレーション先含めてレコード取得
  def self.joined_select(code_array = nil)
    code_array = [code_array.to_s] rescue [] unless code_array.is_a?(Array)

    it = self.table_name
    sk = PmgSku.table_name
    si = MasterSite.table_name
    ma = MasterMall.table_name

    self.select(
      "#{it}.id AS id,
      #{it}.code AS code,
      #{it}.url_code AS url_code,
      #{si}.id AS site_master_id,
      #{si}.code AS site_code,
      #{it}.name AS name,
      #{it}.catch_copy AS name_2,
      #{it}.price AS price,
      #{it}.sale_price AS sale_price,
      #{it}.category_id AS category_id,
      #{it}.display_type AS display_type,
      #{it}.stock_type AS stock_type,
      #{it}.param_1 AS i_param_1,
      #{it}.param_2 AS i_param_2,
      #{it}.param_3 AS i_param_3,
      #{it}.json AS json,
      #{it}.stock AS stock,
      #{it}.delivery_num AS delivery_num,
      #{it}.delivery_date AS delivery_date,
      #{si}.key AS site_key,
      #{ma}.key AS mall_key,
      #{sk}.id AS sku_id,
      #{sk}.sku_code AS sku_code,
      #{sk}.options_type AS option_type,
      #{sk}.options_name AS option_key,
      #{sk}.options AS option_value,
      #{sk}.options_h AS option_h,
      #{sk}.options_h_id AS option_h_id,
      #{sk}.options_v AS option_v,
      #{sk}.options_v_id AS option_v_id,
      #{sk}.display_order AS display_order,
      #{sk}.param_1 AS s_param_1,
      #{sk}.param_2 AS s_param_2,
      #{sk}.param_3 AS s_param_3,
      #{sk}.stock AS s_stock,
      #{sk}.delivery_num AS s_delivery_num,
      #{sk}.delivery_date AS s_delivery_date"
    ).joins(
      "LEFT JOIN #{sk} ON #{it}.url_code = #{sk}.url_code AND #{it}.site_master_id = #{sk}.site_master_id"
    ).joins(
      master_site: :master_mall
    ).where(
      "#{it}.code" => code_array
    ).order("#{it}.code").order("#{it}.url_code").order("#{ma}.key").order("#{si}.key").order("#{sk}.display_order").order("#{sk}.id")
  end
end