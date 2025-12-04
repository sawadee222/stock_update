class Maker::Multi::StartService < Maker::Multi::ApplicationService

  def initialize(prefix: "multi", params: {})
    super(params: params)
  end

  def call()
    Rails.logger.info("start:(#{@@prefix.to_s})")
    result = nil
    message = nil
    begin
      # 初期化処理
      Maker::Multi::InitializeService.new().call

      Maker::Multi::SetDownloadDataService.new().call()
      Common::SetMasterService.new().call(@@download_hash.keys)
      Common::SetUpdateDataService.new().call()
      Common::OutputStockService.new().call()
      Maker::Multi::UploadStockService.new().call(@@result_data)
      # Common::UpdateMasterService.new().call()

      # 終了処理
      Maker::Multi::TerminateService.new().call()

      result = ResultMaster::SUCCESS
    rescue InitializeException, OldFileException, DownloadException, SetStockException, \
      OutputStockException, UploadException, UpdateMasterException, TerminateException => ex
      output_exception(ex)
      result = ResultMaster.find_by(exception: "#{ex.class}")
      message = ex.message
    rescue SyntaxError => ex
      result = ResultMaster::UNKNOWN_ERROR
      message = ex.message
    rescue => ex
      output_exception(ex)
      result = ResultMaster::UNKNOWN_ERROR
      message = ex.message
    ensure
      @@result_data[RESULT_TYPE] = result.message
      Rails.logger.error(result.message)

      @@result_data[MESSAGE_KEY] = message

      Rails.logger.info("end:(#{@@prefix.to_s})")
      return @@result_data
    end
  end

end