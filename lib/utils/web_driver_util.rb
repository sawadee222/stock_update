module Utils::WebDriverUtil

  #
  # Webdriver起動
  #
  def self.start_webdriver(browser_type = nil, profile = nil)
    Rails.logger.debug("start:#{__method__}")

    if browser_type == nil then
      browser_type = Constants::DEFAULT_BROWSER_TYPE
    end

    # Timeout設定
    client = Selenium::WebDriver::Remote::Http::Default.new
    client.read_timeout = Constants::BROWSER_TIMEOUT # seconds – default is 60

    if profile == nil then
      setting = {:http_client => client}
    else
      setting = {:profile => profile, :http_client => client}
    end

    case browser_type
    when SUConstants::Browser_Type_IE then
      browser = Watir::Browser.new :ie, setting
    when SUConstants::Browser_Type_Firefox then
      browser = Watir::Browser.new :firefox, setting
    when SUConstants::Browser_Type_Chrome then
      # chromiumのbin指定
      if Constants::CHROME_PATH != "" then
        Rails.logger.debug("chrome_path set:" + Constants::CHROME_PATH)
        Selenium::WebDriver::Chrome.path = Constants::CHROME_PATH
      end
      browser = Watir::Browser.new :chrome, setting
    else
      browser = start_webdriver()
    end

    Rails.logger.debug("end:#{__method__}")
    return browser
  end

  #
  # WebDriver終了
  #
  def self.stop_webdriver(browser)
    Rails.logger.debug("start:#{__method__}")

    begin
      if browser != nil then
        browser.close
      end
    rescue => ex
    end
    Rails.logger.debug("end:#{__method__}")
  end

  #
  # 指定のurlページにアクセスする
  #
  def self.browser_navigater(browser, url)
    Rails.logger.debug("start:#{__method__}")
    output_browser_info(browser)

    begin
      Rails.logger.debug("browser.goto " + url.to_s)
      browser.goto url

    rescue => ex
      Rails.logger.error(ex.message)
      ex.backtrace.each do |b|
        Rails.logger.error(b)
      end
      raise "browser_navigater error"
    end

    Rails.logger.debug("url:" + browser.url.to_s)
    Rails.logger.debug("title:" + browser.title.to_s)
    Rails.logger.debug("end:#{__method__}")
  end

  #
  # ファイルのダウンロード完了を待つ
  #
  def self.download_wait(download_dir, filekey)
    Rails.logger.debug("start:#{__method__}")

    begin
      flag = true

      filesize_hash = Hash.new()

      if filekey.instance_of?(Array) then
        file_array = filekey.clone()
      else
        file_array = [filekey]
      end

      while true do
        # スリープ(ダウンロード開始待ち)
        Rails.logger.info("sleep(" + Constants::DOWNLOAD_CHECK_SPAN.to_s + ")")
        sleep Constants::DOWNLOAD_CHECK_SPAN

        filelist = Array.new()
        file_array.each do |key|
          tmp_list = Dir.glob(download_dir + File::SEPARATOR + key)
          filelist.concat(tmp_list)
        end

        if filelist.size != 0 then
          hash_flag = false
          filelist.each do |file|
            # ファイルサイズ取得
            filesize = File.size(file)
            Rails.logger.info("size(" + File.basename(file) + "):" + filesize.to_s + "byte")

            # Hashにファイルが存在しない or サイズが異なる場合はHashとフラグを更新する
            if filesize_hash[file] == nil then
              filesize_hash[file] = filesize
              hash_flag = true
            elsif filesize_hash[file] != filesize then
              filesize_hash[file] = filesize
              hash_flag = true
            end
          end

          if hash_flag then
            Rails.logger.debug("Hash Updated")
          else
            Rails.logger.info("download finish")
            break
          end

        else
          Rails.logger.error("download file not exist")
          flag = false
          break
        end
      end

    rescue => ex
      Rails.logger.error(ex.message)
      ex.backtrace.each do |b|
        Rails.logger.error(b)
      end
      flag = false
    end

    Rails.logger.debug("end:#{__method__}")
    return flag
  end
end