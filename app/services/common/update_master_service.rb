class Common::UpdateMasterService < Common::ApplicationService

  def call()
    Rails.logger.debug("start:#{self.class.to_s}")
    begin

      System::MasterManagerService.new().update()
      
    rescue => ex
      output_exception(ex)
      raise UpdateMasterException.new()
    end
    Rails.logger.debug("end:#{self.class.to_s}")
  end
  
end