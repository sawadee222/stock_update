class Parser::SkuParser

  # 在庫更新フラグ
  FLAG_NO_UPDATE = 0 # 在庫更新なし
  FLAG_UPDATE = 1    # 在庫更新あり
  FLAG_NO_CHANGE = 2 # 在庫更新なし(在庫数変化なし)

  def initialize(val = nil)
    case val
    when PmgSku
      @sku = val
    when Hash
      @sku = PmgSku.new(val)
    end
    # 更新フラグ(0:更新なし、1:更新有り、2:更新なし(在庫数変化なし)
    @update_flag = FLAG_NO_UPDATE
  end
  
  attr_accessor :sku
  attr_accessor :update_flag
  

  def id
    @sku.id
  end

  def url_code
    @sku.url_code
  end

  def sku_code
    @sku.code
  end

  def site_master_id
    @sku.site_master_id
  end

  def option_h
    @sku.option_h
  end

  def option_h_id
    @sku.option_h_id
  end

  def option_v
    @sku.option_v
  end

  def option_v_id
    @sku.option_v_id
  end

  def stock
    @sku.stock
  end

  def stock=(val)
    @sku.stock = val
  end

  def param_1
    @sku.s_param_1
  end

  def param_2
    @sku.s_param_2
  end

  def param_3
    @sku.s_param_3
  end
  # 納期管理番号
  def delivery_num
    @sku.delivery_num
  end
  def delivery_num=(val)
    @sku.delivery_num = val
  end
  # リードタイム
  def leadtime_num
    @sku.leadtime_num
  end
  def leadtime_num=(val)
    @sku.leadtime_num = val
  end
  # 入荷予定
  def delivery_date
    @sku.delivery_date
  end

  def site_code
    @sku.site_code
  end

  def mall_key
    @sku.mall_key
  end

  def site_key
    @sku.site_key
  end

  def options_vh_value()
    array = Array.new()
    array.push(comparable_variation(self.option_h))
    array.push(comparable_variation(self.option_v))
    array.compact!()
    array.sort!()
    return array.join("__")
  end

  def comparable_variation(variation)
    variation = variation.to_s.strip()
    return variation if variation.blank?
    return "" if variation.include?("在庫")
    return "" if variation.include?("即日")
    # 文字コードをUTF-8に変更
    variation = variation.to_s.toutf8
    # ASCIIに含まれる記号と英数字(ALNUM|ASYMBOL)を半角に、それ以外の記号とカタカナ( JSYMBOL|HAN_KATA )を全角に変換
    variation = Moji.normalize_zen_han(variation)
    # 全角ハイフン"－"を半角にする
    variation = variation.gsub("－", "-")
    variation = variation.gsub("−", "-")
    # 英小文字を英大文字に変換
    variation = variation.upcase()
    # スペースを取り除く
    variation = variation.gsub(/(\s|　)/,"")
    # 括弧を取り除く
    variation = variation.gsub(/\(.*?\)/, "")
    # "."を取り除く（".0"の場合は0も取り除く）
    variation = variation.gsub(".0", "").gsub(".", "")
    # "_"を取り除く
    variation = variation.gsub("_", "")
    # cm（㎝）を取り除く
    variation = variation.gsub("㎝", "CM")
    variation = variation.gsub("CM", "") if variation =~ /[0-9]CM/
    return variation
  end

end