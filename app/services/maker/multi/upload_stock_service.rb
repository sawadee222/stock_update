class Maker::Multi::UploadStockService < Common::UploadStockService

  def call(result_data)
    Rails.logger.debug("start:#{self.class.to_s}")
    begin
      # バックアップ
      arc_filepath = backup_upload_file()
      FileUtils.rm_rf(@@upload_dir)
      # 共有フォルダへ配置
      public_dir = "#{FileConstants::PUBLIC_DIR}#{File::SEPARATOR}#{@@prefix}"
      FileUtils::mkdir_p(public_dir) unless Dir.exist?(public_dir)
      public_filepath = arc_filepath.present? ? "#{public_dir}#{File::SEPARATOR}#{File.basename(arc_filepath)}" : nil
      FileUtils.cp(arc_filepath, public_filepath) if public_filepath.present?

      result_data[Maker::Multi::StartService::FILE_KEY] = public_filepath.present? ? public_filepath.gsub(FileConstants::PUBLIC_DIR, "") : nil
      
    rescue => ex
      output_exception(ex)
      raise UploadException.new("出力ファイルのzip化に失敗しました。")      
    end
    Rails.logger.debug("end:#{self.class.to_s}")

  end
end