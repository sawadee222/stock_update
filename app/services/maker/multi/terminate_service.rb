class Maker::Multi::TerminateService < Maker::Multi::ApplicationService

  def initialize()
    # インスタンス化の際、クラス変数を上書きしないようにoverrideして無効化
  end

  def call()
    Rails.logger.debug("start:#{self.class.to_s}")
    begin

      backup_download_file()

      FileUtils.rm_rf(@@upload_dir) unless File.exist?(@@upload_dir)

      @@result_data[Maker::Multi::StartService::DATA_KEY] = calculate_data()

    rescue => ex
      output_exception(ex)
      raise TerminateException.new()
    end
    Rails.logger.debug("end:#{self.class.to_s}")
  end

  private
   
  def backup_download_file()
    download_filepath = Dir.glob("#{@@download_dir}#{File::SEPARATOR}#{@@download_filename}")[0]
    if download_filepath && File.exist?(download_filepath) then
      backup_dir = "#{@@download_dir}#{File::SEPARATOR}#{FileConstants::BACKUP_DIR_NAME}"
      Dir::mkdir(backup_dir) unless File.exist?(backup_dir)
      filename = File.basename(download_filepath)
      filename = filename.gsub(File.extname(filename), "_#{@@time.strftime("%Y%m%d%H%M%S")}#{File.extname(filename)}")
      backup_filepath = backup_dir + File::SEPARATOR + filename
      File.rename(download_filepath, backup_filepath)
    end
  end

  def calculate_data()
    data = Array.new()
    @@download_hash.each_value do |item_parser|
      array = Array.new()

      array.push("在庫数更新なし") if item_parser.update_flag == Parser::ItemParser::FLAG_NO_CHANGE

      if item_parser.sku_array.size > 0 then
        array.push("SKU在庫数更新なし") if item_parser.sku_update_flag == Parser::ItemParser::FLAG_NO_CHANGE
      end

      if item_parser.option_array.size > 0 then
        array.push("選択肢更新なし") if item_parser.option_update_flag == Parser::ItemParser::FLAG_NO_CHANGE
      end

      if item_parser.update_flag == Parser::ItemParser::FLAG_NO_UPDATE && \
        item_parser.sku_update_flag == Parser::ItemParser::FLAG_NO_UPDATE && \
        item_parser.option_update_flag == Parser::ItemParser::FLAG_NO_UPDATE then
        array.push("商品番号なし")
      end

      array.push("更新完了") if array.blank?
      data.push([item_parser.code, array.join(",")])
    end
    
    return data
  end
end