class Maker::Nd::DownloadFileService < Maker::DownloadFileService
  
  def download_from_s3()
    download_filepath = super
    password = @@maker_config['zip_pw']
    Utils::FileUtil.extract_zip(download_filepath, password)
  end

  def download_object(file_objects, filekey = nil)
    filekey = "問い番"
    super(file_objects, filekey)
  end

end