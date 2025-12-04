class Parser::ItemParser

  # 在庫タイプ
  STOCK_TYPE_ITEM = 1
  STOCK_TYPE_SKU = 2

  # 更新フラグ
  FLAG_NO_UPDATE = 0 # 在庫更新なし
  FLAG_UPDATE = 1    # 在庫更新あり
  FLAG_NO_CHANGE = 2 # 在庫更新なし(在庫数変化なし)

  def initialize(val = nil)
    case val
    when PmgItem, PmgSku
      @item = val
    when Hash
      @item = PmgItem.new(val)
    end
    @option_array = Array.new()
    @sku_array = Array.new()
    # 更新フラグ
    @update_flag = FLAG_NO_UPDATE
    @option_update_flag = FLAG_NO_UPDATE
    @sku_update_flag = FLAG_NO_UPDATE
  end

  attr_accessor :item
  attr_accessor :option_array
  attr_accessor :sku_array
  attr_accessor :update_flag
  attr_accessor :option_update_flag
  attr_accessor :sku_update_flag

  def id
    @item.id
  end
  # 商品番号
  def code
    @item.code
  end
  # 商品管理番号
  def url_code
    @item.url_code
  end
  # サイトマスタID
  def site_master_id
    @item.site_master_id
  end
  # サイト識別子
  def site_code
    @item.site_code
  end
  # モール名
  def mall_key
    @item.mall_key
  end
  # サイト名
  def site_key
    @item.site_key
  end
  # # 商品名
  # def name
  #   @item[:name]
  # end
  # # キャッチコピー
  # def name_2
  #   @item[:catch_copy]
  # end
  # # 販売価格
  # def price
  #   @item[:price]
  # end
  # # セール価格
  # def sale_price
  #   @item[:sale_price]
  # end
  # ディレクトリID
  def category_id
    @item.category_id
  end
  #公開区分
  def display_type
    @item.display_type
  end
  # 在庫タイプ
  def stock_type
    @item.stock_type
  end
  # 在庫数
  def stock
    @item.stock
  end
  def stock=(val)
    @item.stock = val
  end
  # 納期管理番号
  def delivery_num
    @item.delivery_num
  end
  def delivery_num=(val)
    @item.delivery_num = val
  end
  # 入荷予定日
  def delivery_date
    @item.delivery_date
  end
  # リードタイム
  def leadtime_num
    @item.leadtime_num
  end
  def leadtime_num=(val)
    @item.leadtime_num = val
  end
  # ○○予定日
  def supply_date
    @item.supply_date
  end
  # 固有値1
  def param_1
    @item.i_param_1
  end
  # 固有値2
  def param_2
    @item.i_param_2
  end
  # 固有値1
  def param_3
    @item.i_param_3
  end
  # JSON
  def json
    @item.json
  end

  def has_valid_option?()
    return false unless self.option_array.size > 0
    self.option_array.any?{|option_parser| option_parser.valid_option?}
  end
  
end