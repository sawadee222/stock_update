class Mall::Amazon::OutputService < Mall::OutputService

  # item.csv
  def get_item_stock_rows(item_parser, stock)
    stock = 0 unless salable?(item_parser)
    delivery_date = stock > 0 ? parse_date_obj(item_parser.delivery_date) : nil
    leadtime_num = item_parser.leadtime_num || item_parser.delivery_num
    [item_parser.url_code, nil, nil, stock, nil, nil, nil, nil, nil, delivery_date, nil, nil, nil, leadtime_num]
  end


  # ------ Amazon 独自処理 --------#

  MAX_LEADTIME_TO_SELL = 15
  SALABLE_DELIVERY_NUMS = ["1", "2", "3", "4", "5", "6", "7", "11", "15", "17", "18", "19", "20", "22", "23", "24", "25", "26", "27", "31", "70", "71", "72", "73", "74", "75", "76", "83"]


  # 出力ファイルのヘッダーを取得
  # 複数行出力
  def get_output_header_str(filename)
    output_str = ""
    "MallConstants::#{get_mall_name()}::HEADER".constantize[filename].each do |row|
      output_str += CSV.generate_line(row, {col_sep: "\t"}).tosjis
    end

    return output_str
  end

  # override
  # タブ区切りに変換
  def get_output_item_stock_str(item_parser)
    output_str = super
    output_str.gsub(/,/,"\t").tosjis
  end

  #
  def salable?(item_parser)
    return false if item_parser.leadtime_num.to_i >= MAX_LEADTIME_TO_SELL
    date_obj = parse_date_obj(item_parser.delivery_date)
    if date_obj && item_parser.supply_date.present? then
      # 入荷予定日が指定の日数より先の日付の場合はカートを閉じる
      return false if (date_obj - Date.today) >= MAX_LEADTIME_TO_SELL
    else
      # 入荷予定日また納品予定日が未設定の場合のみ楽天納期管理番号で判定する
      return false if !SALABLE_DELIVERY_NUMS.include?(item_parser.delivery_num.to_s)
    end
    return true
  end
  
  # ------ Amazon 独自処理 end --------#

end