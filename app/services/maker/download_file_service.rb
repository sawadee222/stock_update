class Maker::DownloadFileService < Maker::ApplicationService

  def call()
    Rails.logger.debug("start:#{self.class.to_s}")

    Dir::mkdir(@@download_dir) unless Dir.exist?(@@download_dir)
    case @@maker_config['source']
    # 在庫表をS3からダウンロード
    when Constants::FILE_SOURCE_MAIL then
      download_from_s3()
    # 在庫表をWebからダウンロード
    when Constants::FILE_SOURCE_WEB then
      download_from_web()
    end
    
    Rails.logger.debug("end:#{self.class.to_s}")
  end

  private

  def download_from_s3(prefix = nil)
    prefix ||= @@prefix
    begin
      bucket = Aws::S3::Resource.new(
        :region => Constants::AWS_DEFAULT_REGION,
        :access_key_id => Constants::AWS_ACCESS_KEY_ID,
        :secret_access_key => Constants::AWS_SECRET_ACCESS_KEY
      ).bucket(Constants::S3_BUCKET_NAME)

      file_objects = bucket.objects(
        # backupフォルダ内のファイルは対象外
        :prefix => Constants::S3_STORAGE_PATH + "/" + prefix
      ).select{|object| !object.key.include?('backup')}

      raise "new stock data mail nothing." unless file_objects

      download_filepath = download_object(file_objects)

      raise "download file nothing" unless download_filepath

    rescue OldFileException => ex
      raise OldFileException.new()
    rescue => ex
      output_exception(ex)
      raise DownloadException.new()
    end

    return download_filepath
  end

  def download_object(file_objects, filekey = nil)

    filekey ||= @@maker_config['filekey']
    last_update = Time.parse(@@maker_config['latest_file_date'])
    Rails.logger.debug("last_update:" + last_update.strftime("%Y/%m/%d %H:%M:%S"))

    download_filepath = ""
    latest_file_flag = true

    file_objects.each do |object|
      # ファイル名の判定
      object_name = File.basename(object.key).unicode_normalize(:nfkc)
      next unless object_name =~ /.*#{delete_space(filekey.to_s)}/
      # ファイル日時の判定
      object_date = object.last_modified # 標準時UTC
      # 取得したファイルが前回取得したファイルより新しいか判定する
      if (object_date <=> last_update) == 1 then
        latest_file_flag = true
        @@maker_config['latest_file_date'] = (object_date  + 32400).strftime("%Y/%m/%d %H:%M:%S") # 標準時UTC + 9時間(s)
      else
        latest_file_flag = false unless Rails.env.test?
        next
      end
      download_filepath = @@download_dir + File::SEPARATOR + "#{filekey.to_s}#{File.extname(object_name.to_s)}"
      File.open(download_filepath, "w+b") do |f|
        f.write(object.get.body.read)
      end
      Rails.logger.info("Download Finish:" + File.basename(download_filepath))
      break
    end
    raise OldFileException.new() unless latest_file_flag

    return download_filepath
  end


  # 各メーカーのクラスでoverrideして使用
  def download_from_web()
    # # Webdriverの設定
    # options = Selenium::WebDriver::Options.chrome
    # options.binary = "#{Rails.root}/chromium/chrome"
    # # Webdriver起動
    # session = Selenium::WebDriver.for :chrome, options: options
  end

end