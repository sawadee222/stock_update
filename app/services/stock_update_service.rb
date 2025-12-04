class StockUpdateService < ApplicationService
  
  def initialize(prefix)
    super
  end

  def call()
    Rails.logger.info("start:(#{@@prefix.to_s})")
    result = nil
    message = nil
    begin
      
      # 各メーカーの在庫更新実行
      "Maker::#{@@prefix.capitalize}::StartService".classify.constantize.new().call() rescue Maker::StartService.new().call()

      result = ResultMaster::SUCCESS
    rescue InitializeException, OldFileException, DownloadException, SetStockException, \
      OutputStockException, UploadException, UpdateMasterException, TerminateException => ex
      output_exception(ex)
      result = ResultMaster.find_by(exception: "#{ex.class}")
      message = ex.message
    rescue SyntaxError, NoMethodError => ex
      result = ResultMaster::UNKNOWN_ERROR
      message = ex.message
    rescue => ex
      output_exception(ex)
      result = ResultMaster::UNKNOWN_ERROR
      message = ex.message
    ensure
      output_message(result, message)
      Rails.logger.info("end:(#{@@prefix.to_s})")
    end
    
  end

  private
   
  def output_message(result_master, message)
    result_message = result_master.message if result_master
    # 正常系の結果コードは"0XX"
    if result_master.present? && result_master[:code] =~ /^0.+/ then
      Rails.logger.info(result_message)
    # 正常系以外の結果コードの場合はメール送信(production環境のみ)
    else
      Rails.logger.error(result_message)
      Rails.logger.error(message)
      if Rails.env.production? then
        CommonUtil.send_mail()
        InternalUtil.push_error_history(message)
      end
    end
  end

end