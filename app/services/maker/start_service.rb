class Maker::StartService < Maker::ApplicationService
  
  def call()
    # 初期化処理
    System::InitializeService.new().call
    # メーカーの処理
    "Maker::#{@@prefix.capitalize}::DownloadFileService".classify.constantize.new().call() rescue Maker::DownloadFileService.new().call()
    "Maker::#{@@prefix.capitalize}::SetDownloadDataService".classify.constantize.new().call() rescue Maker::SetDownloadDataService.new().call()
    # 共通処理
    Common::SetMasterService.new().call()
    Common::SetUpdateDataService.new().call()
    Common::OutputStockService.new().call()
    Common::UploadStockService.new().call
    # Common::UpdateMasterService.new().call()
    # 終了処理
    System::TerminateService.new().call()
  end

end