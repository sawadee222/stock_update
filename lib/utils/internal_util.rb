module Utils::InternalUtil

  # host
  HOST = EasySettings.internal.host
  # URL
  URL = "http://#{HOST}"


  # エラー履歴登録
  def self.push_error_history(prefix = "", maker_name = "", error_code = "", error_message = "")
    path = "/api/item_manager/stockupdate/error"
    params = {prefix: prefix, maker_name: maker_name, error_code: error_code, error_message: error_message}
    post(path, params)
  end

  # Web紐づけマスタ取得
  def self.get_linking_master(prefix)
    path = "/item_manager/stock_update_tyings/get_tying/#{prefix}"
    get_json(path)
  end

  # 納期管理番号マスタ取得
  def self.get_leadtime_master()
    path = "/api/item_manager/rakuten_lead_time_masters/get"
    get_json(path)['data']
  end

  # 休業日設定取得
  def self.get_holiday_setting()
    holiday_setting = Hash.new()
    path = "/api/item_manager/stock_update_closed/get"
    get_json(path)['types'].each do |data|
      holiday_setting.store(data['key'], data['configurations'].map{|v,k| [v['before_value'].to_s, v['after_value'].to_s] }.to_h)
    end
  end

  # 休業日判定取得
  def self.get_holiday_judgement()
    path = "/api/item_manager/stock_update_closed/is_closed?date=#{Date.today().strftime("%Y-%m-%d").to_s}"
    get_json(path)
  end

  # スキップ対象の商品番号を取得
  def self.get_skip_code_hash()
    skip_code_hash = Hash.new()

    path = "/item_manager/stock_update_excludes/get_all"
    get_json(path).each do |code|
      skip_code_hash.store(code, true) unless skip_code_hash.has_key?(code)
    end
    # 積商品の品番取得
    path = "/api/order_manager/item_codes/stock_item_codes"
    get_json(path).each do |code|
      skip_code_hash.store(code, true) unless skip_code_hash.has_key?(code)
    end
    
    Rails.logger.info("skip_code_hash: #{skip_code_hash.size}")
    skip_code_hash
  end

  # スキップ対象の商品ページを取得
  def self.get_skip_page_hash()
    skip_page_hash = Hash.new()

    path = "/item_manager/stock_update_exclude_pages/get_all"
    get_json(path).each do |page|
      next if page["valid"].to_s != "1"
      url_code = page["url_code"].to_s
      mall_key = page["mall_key"].to_s
      site_key = page["site_key"].to_s
      skip_page_hash.store(url_code, Hash.new()) unless skip_page_hash.has_key?(url_code)
      skip_page_hash[url_code].store(mall_key, Hash.new()) unless skip_page_hash[url_code].has_key?(mall_key)
      skip_page_hash[url_code][mall_key].store(site_key, true)
    end

    Rails.logger.info("skip_page_hash: #{skip_page_hash.size}")
    skip_page_hash
  end

  # GET(JSON)
  def self.get_json(path)
    url = "#{URL}#{path}"
    client = HTTPClient.new
    json_text = client.get_content(url)
    JSON.load(json_text)
  end

  # GET
  def self.get(path, params = nil)
    url = "#{URL}#{path}"
    uri = URI.parse(url)
    # Getリクエスト作成
    request = Net::HTTP::Get.new(uri.request_uri)
    request['Content-Type'] = "application/json"

    JSON.parse(request(uri, request).body)
  end

  # POST
  def self.post(path, params)
    url = "#{URL}#{path}"
    uri = URI.parse(url)
    # Postリクエスト作成
    request = Net::HTTP::Post.new(uri.request_uri)
    request['Content-Type'] = "application/json"
    # bodyに設定
    request.body = params.to_json

    request(uri, request)    
  end

  # Request
  def self.request(uri, request)
    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = false
    https.verify_mode = OpenSSL::SSL::VERIFY_NONE

    response(https.request(request))
  end

  # レスポンス内容をチェック
  def self.response(response)
    res_code = response.code
    # codeが200以外だったらエラー処理
    unless res_code.to_s == "200" then
      raise BaseException.new("API Error(#{res_code}):#{JSON.parse(response.body)}")
    end

    return response
  end

end