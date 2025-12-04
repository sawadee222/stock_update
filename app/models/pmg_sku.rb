class PmgSku < ApplicationRecord

  belongs_to :master_site, foreign_key: :site_master_id

  validates :url_code, presence: true
  validates :site_master_id, presence: true

  attribute :id
  attribute :code
  attribute :url_code
  attribute :site_master_id
  attribute :site_code
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
  attribute :stock
  attribute :delivery_num
  attribute :delivery_date
  attribute :site_key
  attribute :mall_key
  attribute :item_id
  attribute :item_code
  attribute :i_param_1
  attribute :i_param_2
  attribute :i_param_3
  attribute :stock_type, default: 1
  # 以降DBに無し（在庫表にあり）
  attribute :leadtime_num

  attr_accessor :item_parser
  attr_accessor :option_parser
  attr_accessor :sku_parser

  ITEM_ATTR_MAPPING = {
    "id" => :sku_id,
    "code" => :sku_code,
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
    "stock" => :s_stock,
    "s_param_1" => :s_param_1,
    "s_param_2" => :s_param_2,
    "s_param_3" => :s_param_3,
    "delivery_num" => :s_delivery_num,
    "delivery_date" => :s_delivery_date,
    "site_key" => :site_key,
    "mall_key" => :mall_key,
    "item_id" => :id,
    "item_code" => :code,
    "i_param_1" => :i_param_1,
    "i_param_2" => :i_param_2,
    "i_param_3" => :i_param_3,
  }

  def item_parser()
    @item_parser = Parser::ItemParser.new(self)
  end

  def option_parser()
    @option_parser = Parser::OptionParser.new(self)
  end

  def sku_parser()
    @sku_parser = Parser::SkuParser.new(self)
  end

  # PmgItemに変換
  def pmg_item()
    PmgItem.new(item_attr_hash())
  end

  def item_attr_hash()
    attr_hash = Hash.new()
    self.attributes.each do |key, value|
      attr_hash.store(ITEM_ATTR_MAPPING[key], value) if ITEM_ATTR_MAPPING.has_key?(key)
    end

    return attr_hash
  end

  # pmg_skus.sku_codeで検索してリレーション先含めてレコード取得
  def self.joined_select(code_array = nil)
    code_array = [code_array.to_s] rescue [] unless code_array.is_a?(Array)

    it = PmgItem.table_name
    sk = self.table_name
    si = MasterSite.table_name
    ma = MasterMall.table_name

    self.select(
      "#{sk}.id AS id,
      #{sk}.sku_code AS code,
      #{sk}.url_code AS url_code,
      #{si}.id AS site_master_id,
      #{si}.code AS site_code,
      #{sk}.options_h AS option_h,
      #{sk}.options_h_id AS option_h_id,
      #{sk}.options_v AS option_v,
      #{sk}.options_v_id AS option_v_id,
      #{sk}.param_1 AS s_param_1,
      #{sk}.param_2 AS s_param_2,
      #{sk}.param_3 AS s_param_3,
      #{sk}.stock AS stock,
      #{sk}.delivery_num AS delivery_num,
      #{sk}.delivery_date AS delivery_date,
      #{si}.key AS site_key,
      #{ma}.key AS mall_key,
      #{it}.id AS item_id,
      #{it}.code AS item_code,
      #{it}.param_1 AS i_param_1,
      #{it}.param_2 AS i_param_2,
      #{it}.param_3 AS i_param_3"
    ).joins(
      "LEFT JOIN #{it} ON #{it}.url_code = #{sk}.url_code AND #{it}.site_master_id = #{sk}.site_master_id"
    ).joins(
      master_site: :master_mall
    ).where(
      "#{sk}.sku_code" => code_array
    ).order("#{it}.code").order("#{it}.url_code").order("#{ma}.key").order("#{si}.key").order("#{sk}.id")
  end

end