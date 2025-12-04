class Maker::At::DownloadFileService < Maker::DownloadFileService

  FTP_HOST = "zaiko.trusco-edi.com"
  FTP_ID = "00012889"
  FTP_PW = "sn2889"
  # FTPサーバからダウンロードしてくるファイル名
  ARCHIVE_DIR = "FILE31NF.zip"
  ARCHIVE_FILENAME = "FILE31NF.zip"

  def download_from_web()
    begin
      arc_filepath = @@download_dir + File::SEPARATOR + ARCHIVE_FILENAME

      # ftpサーバからダウンロード
      @ftp = Utils::FtpUploadUtil.new(FTP_HOST, FTP_ID, FTP_PW)
      @ftp.download(ARCHIVE_DIR, ARCHIVE_FILENAME)
      @ftp.close
      raise "FTPサーバーから在庫表をダウンロードできませんでした。" unless File.exist?(arc_filepath)

      # ダウンロードしたファイルを解凍
      filepath_array = Utils::FileUtil.extract_zip(arc_filepath)
      # ファイル名を変更
      if filepath_array.size > 0 && File.exist?(filepath_array[0]) then
        filepath = @@download_dir + File::SEPARATOR + @@maker_config['filekey']
        File.rename(filepath_array[0], filepath)
        Rails.logger.debug("rename:#{File.basename(filepath_array[0])} -> #{File.basename(filepath)}")
      end
      # ダウンロードしたファイルをバックアップ
      backup_dir = @@download_dir + File::SEPARATOR + FileConstants::BACKUP_DIR_NAME
      Dir::mkdir(backup_dir) unless File.exist?(backup_dir)
      backup_filename = ARCHIVE_FILENAME.gsub(File.extname(ARCHIVE_FILENAME), "_" + Time.now.strftime("%Y%m%d%H%M%S") + File.extname(ARCHIVE_FILENAME))
      backup_filepath = backup_dir + File::SEPARATOR + backup_filename
      File.rename(arc_filepath, backup_filepath)
      Rails.logger.debug("backup: #{File.basename(backup_filepath)}")

    rescue => ex
      output_exception(ex)
      raise DownloadException.new()
    end
  end

end