module Utils::FileUtil

  # zip化
  def self.archive_file(arc_filepath, filelist)
    Zip::File.open(arc_filepath, Zip::File::CREATE) do |ar|
      filelist.each {|filepath|
        ar.add(File.basename(filepath), filepath)
      }
    end
  end

  # zip解凍
  def self.extract_zip(filepath, password)
    Rails.logger.info("start:#{__method__}")
    filepath_array = Array.new()
    entrys = Array.new
    begin
      # zipパスワードを作成
      zip_pw = password.present? ? Zip::TraditionalDecrypter.new(password) : nil
      Zip.unicode_names=true
      Zip::InputStream.open(filepath, 0, zip_pw) do |input|
        while (entry = input.get_next_entry)
          break if entry.nil?
          save_path = File.join(File.dirname(filepath) + File::SEPARATOR, entry.name.toutf8)
          if entry.file? && !entry.name.toutf8().end_with?("/")
            File.binwrite save_path, input.read
            filepath_array.push(save_path)
          end
          Rails.logger.info("zipファイルの解凍が完了しました。: #{save_path}")
        end
      end
    rescue => ex
      raise DownloadException.new("zipファイルの解凍に失敗しました。#{File.basename(filepath)}")
    end

    Rails.logger.info("end:#{__method__}")
    
    return filepath_array
  end

end
