class Utils::FtpUtil

  def initialize(host, user, pw)
    begin
      @ftp = Net::FTP.new(host, ssl: {verify_mode: OpenSSL::SSL::VERIFY_NONE}, username: user, password: pw)
    rescue => ex
      output_exception(ex)
      raise BaseException.new("FTPサーバーとの接続に失敗しました。")
    end
  end

  def exist?(dir, regexp)
    result = false
    @ftp.chdir(dir)
    file_list = @ftp.list()
    Rails.logger.debug(file_list)
    file_list.each do |file|
      result = true if file =~ /#{regexp}/
    end

    return result
  end

  def download(dir, regexp)
    file_list = @ftp.list()
    file_list.each do |file|
      @ftp.get("#{dir}/#{File.basename(file)}") if file =~ /#{regexp}/
    end
  end

  def upload(dir, filepath)
    remote_filepath = "#{dir}/#{File.basename(filepath)}"
    Rails.logger.debug("upload_file: #{filepath}  remote_filepath: #{remote_filepath}")
    @ftp.put(filepath, remote_filepath)
  end

  def set_binary(bool)
    @ftp.binary = bool
  end

  def set_passive(bool)
    @ftp.default_passive = bool
  end

  def close()
    @ftp.close
  end
end