class Maker::Multi::ApplicationService < ApplicationService

  RESULT_TYPE = :result_master
  FILE_KEY = :file
  DATA_KEY = :data
  MESSAGE_KEY = :msg
  
  def initialize(prefix: "multi", params: {})
    super(prefix)
    @@download_filename = params[:file].original_filename
    @@maker_config = {'filekey' => File.basename(@@download_filename, ".*")}
    @@time = Time.now()
    @@upload_dir = @@upload_dir + File::SEPARATOR + @@time.strftime("%Y%m%d%H%M%S")
    @@result_data = {
      RESULT_TYPE => nil,
      MESSAGE_KEY => nil,
      FILE_KEY => nil,
      DATA_KEY => Hash.new()
    }
    # 画面のチェックボックスの設定を反映
    @@option_update_flag = params[:options].to_s == "1" ? true : false
    @@sspage_update_flag = params[:sspage].to_s == "1" ? true : false
    @@sale_update_flag = params[:sale].to_s == "1" ? true : false
  end
end