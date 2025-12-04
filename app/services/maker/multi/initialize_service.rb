class Maker::Multi::InitializeService < Maker::Multi::ApplicationService

  def initialize()
    # インスタンス化の際、クラス変数を上書きしないようにoverrideして無効化
  end

  def call()
    Rails.logger.debug("start:#{self.class.to_s}")
    begin
      update_option_flag()
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