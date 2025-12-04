class Parser::OptionParser

  # 更新フラグ
  FLAG_DELETE = -1 # 在庫更新あり（削除）
  FLAG_NO_UPDATE = 0 # 在庫更新なし
  FLAG_UPDATE = 1    # 在庫更新あり
  FLAG_NO_CHANGE = 2 # 更新なし(変化なし)
  FLAG_INSERT = 3 # 更新あり（登録）
  FLAG_DELETE_INSERT = 4 # 更新あり（再登録）

  # 表示順
  NO_DISPLAY_ORDER = -1 # 非表示

  def initialize(val = nil)
    case val
    when PmgSku
      @option = val
    when Hash
      @option = PmgSku.new(val)
    end
    # 更新フラグ(0:更新なし、1:更新有り、2:更新なし(在庫数変化なし)
    @update_flag = FLAG_NO_UPDATE
  end

  attr_accessor :option
  attr_accessor :update_flag
  

  def url_code
    @option.url_code
  end

  def option_key
    @option.option_key
  end
  def option_key=(val)
    @option.option_key = val
  end

  def option_value
    @option.option_value
  end
  def option_value=(val)
    @option.option_value = val
  end

  def display_order
    @option.display_order
  end

  def display_order=(val)
    @option.display_order=val
  end

  def delivery_date
    @option.delivery_date
  end

  def param_1
    @option.s_param_1
  end

  def param_2
    @option.s_param_2
  end

  def param_3
    @option.s_param_3
  end

  def compare_str()
    [self.option_key, self.option_value].join("__")
  end

  def valid_option?
    return false if self.display_order == Parser::OptionParser::NO_DISPLAY_ORDER
    return false if self.option_key.to_s.include?("※")
    return false if self.option_key.to_s.include?("配送")
    return false if self.option_value.to_s.include?("了承")
    return false if self.option_value.to_s.include?("承諾")
    return true
  end

end