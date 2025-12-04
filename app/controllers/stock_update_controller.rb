class StockUpdateController < ApplicationController
  
  skip_before_action :verify_authenticity_token

  def index

  end
  
  def execute
    Rails.logger.info(params)
    @result = nil
    @message = nil
    @filepath = nil
    @data = nil
    @alert = nil

    begin
      uploaded_file = params[:file]
      # ファイル配置
      if uploaded_file.present? then
        filepath = Rails.root.join("download/multi/#{uploaded_file.original_filename}")
        File.open(filepath, 'w+b') do |file|
          file.write(uploaded_file.read)
        end
        # 在庫更新実行
        result_data = run(params)[0]
        Rails.logger.info(result_data)
        # 画面表示用変数
        @result = result_data[Maker::Multi::StartService::RESULT_TYPE]
        @message = result_data[Maker::Multi::StartService::MESSAGE_KEY]
        @filepath = result_data[Maker::Multi::StartService::FILE_KEY]
        @data = result_data[Maker::Multi::StartService::DATA_KEY]
      else
        @alert = uploaded_file.blank? ? "ファイルを設定して下さい。" : nil
      end
    rescue => ex
      Rails.logger.error(ex.message)
    ensure
      respond_to do |format|
        format.js
      end

    end
  end
  
  private
  
  def run(params)
    begin
      result, message = Maker::Multi::StartService.new(params: params).call
      
    rescue => ex
      result = ResultMaster::UNKNOWN_ERROR
      message = "unknown error(#{ex.message})"
    end
    
    return result, message
  end
  
  def form_params
    params.permit(:order_transaction, :mode, site_codes: [])
  end

end
