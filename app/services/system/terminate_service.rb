class System::TerminateService < System::ApplicationService

  def call()
    Rails.logger.debug("start:#{self.class.to_s}")
    begin
      update_latest_file_date()
    rescue => ex
      output_exception(ex)
      raise TerminateException.new()
    end
    Rails.logger.debug("end:#{self.class.to_s}")
  end

  private
   
  def update_latest_file_date()
    return if Rails.env.test?
    # TODO DB化した後は、APIで更新をかけるようにする
    config = YAML.load_file(Rails.root.join('config', 'makers.yml'))
    config[@@prefix] = @@maker_config
    File.open(Rails.root.join('config', 'makers.yml'), 'w') do |file|
      YAML.dump(config, file)
    end
  end

end