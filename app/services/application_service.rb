class ApplicationService

  def initialize(prefix)
    @@prefix = prefix
    # @@maker_config = Rails.application.config_for(:makers)[@@prefix]
    @@maker_config =  YAML.load_file(Rails.root.join('config', 'makers.yml'))[@@prefix]
    @@option_update_flag = true
    @@sspage_update_flag = false
    @@salepage_update_flag = false
    @@download_dir = FileConstants::DOWNLOAD_DIR + File::SEPARATOR + @@prefix
    @@upload_dir = FileConstants::UPLOAD_DIR + File::SEPARATOR + @@prefix
    @@os_download_dir = FileConstants::OS_DOWNLOAD_DIR
    @@master_hash = Hash.new()
    @@download_hash = Hash.new()
    @@updated_parsers = Array.new()
    @@long_vacation_setting_flag = true
  end

  def output_exception(ex)
    Rails.logger.error(ex.message)
    ex.backtrace.each do |b|
      Rails.logger.error(b)
    end
  end

  def delete_space(str)
    str.gsub(/(\s|　)/,"")
    str.gsub(/\t/,"")
    str.gsub(/(\xc2\xa0)/, "")
    str.gsub(/(\r\n?|\n)/,"")
  end
end
