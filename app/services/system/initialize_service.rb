class System::InitializeService < System::ApplicationService

  def call()
    Rails.logger.debug("start:#{self.class.to_s}")
    begin
      update_option_flag()
      os_download_file_delete()
      old_download_file_delete()
      old_upload_file_delete()
    rescue => ex
      output_exception(ex)
      raise InitializeException.new()
    end
    Rails.logger.debug("end:#{self.class.to_s}")
  end
  
  private

  # 選択肢更新停止フラグが存在する場合は、選択肢更新フラグをfalseにする
  def update_option_flag()
    if @@option_update_flag && File.exist?(FileConstants::OPTION_STOP_FLAG)
      Rails.logger.info("option update stop")
      @@option_update_flag = false
    end
  end

  # OSのダウンロードディレクトリに在庫表が存在する場合は削除
  def os_download_file_delete()
    filekey = @@maker_config['filekey']
    file_array = filekey.instance_of?(Array) ? filekey.clone() : [filekey]
    file_array.each do |filekey|
      Dir.glob(@@os_download_dir + File::SEPARATOR + filekey).each do |filepath|
        File.delete(filepath)
        Rails.logger.debug("file_delete #{filepath.to_s}")
      end
    end
  end

  # ダウンロードディレクトリに在庫表が存在する場合は削除
  def old_download_file_delete()
    Dir.glob(@@download_dir + File::SEPARATOR + "*").each do |filepath|
      if File.file?(filepath) then
        File.delete(filepath)
        Rails.logger.debug("file_delete #{filepath.to_s}")
      end
    end
  end

  # アップロードディレクトリに在庫表が存在する場合は削除
  def old_upload_file_delete()
    Dir.glob(@@upload_dir + File::SEPARATOR + "*").each do |filepath|
      if File.file?(filepath) then
        File.delete(filepath)
        Rails.logger.debug("file_delete #{filepath.to_s}")
      end
    end
  end

end