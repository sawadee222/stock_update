class Utils::StringUtil

  #
  # 日付の文字列をDateオブジェクトに変換する
  #
  def self.to_date_object(str)
    str = str.to_s.gsub(/(\s|　)/,"")
    # 空の場合はnil
    return nil if str.to_s == ""
    str = str.tr('０-９','0-9')
    str = str.gsub(".", "/")
    str = str.gsub("-", "/")
    str = str.gsub("年", "/")
    str = str.gsub("月", "/")
    # 文言を日付に変換
    if str =~ /(上|中|下|初|初め|末)(|旬|頃|旬頃|旬頃見込み|旬頃予定|旬入荷予定|旬予定|予定)/ then
      day_hash = { "初" => "1", "初め" => "1", "上" => "1", "中" => "6", "下" => "16", "末" => "26" }
      str = str.gsub(/[#{day_hash.keys.join}]/) do |match|
        day_hash[match]
      end
    end
    # "～"を含む場合
    str = str.split('～')[-1] if str.include?('～')

    # 数字と"/"以外を取り除く
    str = str.gsub(/[^0-9\/]/, "")

    return Date.parse(str) rescue nil
  end

  #
  # Dateオブジェクトを納期文言に変換
  #
  def self.date_to_delivery_string(delivery_date)
    begin
      day = delivery_date.day
      if day >= 1 && day <= 5 then
        footer = "上旬"
      elsif day >= 6 && day <= 15 then
        footer = "中旬"
      elsif day >= 16 && day <= 25 then
        footer = "下旬"
      elsif day >= 26 && day <= 31 then
        date = delivery_date + 7
        footer = "上旬"
      else
        raise "unknown date"
      end
      delivery_string = "#{delivery_date.month.to_s}月#{footer.to_s}"
    rescue => ex
      output_exception(ex)
    end
    return delivery_string
  end

  def self.date_to_delivery_num(date)
    begin
      return nil if date.blank?
      
      num = 0
      day = date.day
      if 1 <= day && day <= 5 then
        num = 0
      elsif 6 <= day && day <= 15 then
        num = 1
      elsif 16 <= day && day <= 25 then
        num = 2
      elsif 26 <= day && day <= 31 then
        date = date + 7
        num = 0
      else
        raise "unknown date"
      end
      delivery_num = 19 + (date.month * 3) + num
    rescue => ex
      output_exception(ex)
    end
    return delivery_num
  end

end