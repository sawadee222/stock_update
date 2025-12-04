class Common::SetMasterService < Common::ApplicationService


  def call(code_array = [])
    Rails.logger.debug("start:#{self.class.to_s}")
    begin
      
      System::MasterManagerService.new().fetch(code_array)
      
      delete_skip_site()
      # delete_skip_code()
      delete_skip_sspage_url_code() unless @@sspage_update_flag
      delete_skip_sale_url_code() unless @@salepage_update_flag
      # delete_skip_page()
      
    rescue => ex
      output_exception(ex)
      raise "在庫マスタの取得に失敗しました。"
    end
    Rails.logger.debug("end:#{self.class.to_s}")
  end
  
  private

  # スキップ対象の店舗を除外
  def delete_skip_site()
    Rails.logger.debug("delete skip site(before):#{@@master_hash.size.to_s}")
    
    Rails.logger.debug("delete skip site(after):#{@@master_hash.size.to_s}")
  end
  
  # スキップ対象の商品番号を除外
  def delete_skip_code()
    Rails.logger.debug("delete skip code(before):#{@@master_hash.size.to_s}")

    skip_code_hash = Utils::InternalUtil.get_skip_code_hash()
    @@master_hash.delete_if {|code, item_parser_array| skip_code_hash.has_key?(code)}

    Rails.logger.debug("delete skip code(after):#{@@master_hash.size.to_s}")
  end
  
  # ssサーチページの商品管理番号を除外
  def delete_skip_sspage_url_code()
    #
  end

  # セールページの商品管理番号を除外
  def delete_skip_sale_url_code()
    #
  end

  # スキップ対象の商品ページを除外
  def delete_skip_page()
    Rails.logger.debug("delete skip pgae(before):#{@@master_hash.size.to_s}")
  
    skip_page_hash = Utils::InternalUtil.get_skip_page_hash()
    @@master_hash.each do |code, item_parser_array|
      item_parser_array.delete_if{|item_parser| skip_page?(item_parser, skip_page_hash)}
      @@master_hash.delete(code) if item_parser_array.size == 0
    end
  
    Rails.logger.debug("delete skip page(after):#{@@master_hash.size.to_s}")
  end

  def skip_page?(item_parser, skip_page_hash)
    # -jdwwのページは除外対象とする
    if item_parser.url_code.to_s =~ /\-jdww$/ then
      Rails.logger.debug("jdww page:#{[item_parser.url_code,item_parser.mall_key,item_parser.site_key].join(",")}")
      return true
    end
    # -fbaのページは除外対象とする
    if item_parser.url_code.to_s.include?("-fba") then
      @@log.debug("fba page:#{[item_parser.url_code,item_parser.mall_key,item_parser.site_key].join(",")}")
      return true
    end
    return false unless skip_page_hash.has_key?(item_parser.url_code.to_s)
    return false unless skip_page_hash[item_parser.url_code.to_s].has_key?(item_parser.mall_key.to_s)
    return false unless skip_page_hash[item_parser.url_code.to_s][item_parser.mall_key.to_s].has_key?(item_parser.site_key.to_s)
    return true
  end

end