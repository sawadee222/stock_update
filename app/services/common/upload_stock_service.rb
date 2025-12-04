class Common::UploadStockService < Common::ApplicationService

  def call()
    Rails.logger.debug("start:#{self.class.to_s}")
    begin
      upload_stock_file()
    rescue => ex
      output_exception(ex)
      raise UploadException.new()
    ensure
      backup_upload_file()
    end
    Rails.logger.debug("end:#{self.class.to_s}")
  end
  
  private

  # ファイルをアップロードする
  def upload_stock_file()
    MasterMall.all.each do |mall_master|
      mall_master.master_sites.each do |site_master|
        mall_key = mall_master.key.to_s
        site_key = site_master.key.to_s
        filelist = Dir.glob("#{@@upload_dir}#{File::SEPARATOR}#{mall_key}_#{site_key}_*")
        filelist.delete_if{|filepath| get_upload_filename(filepath, mall_key, site_key) == nil}
        if filelist.size > 0 then
          post_stock_file(filelist, mall_key, site_key)
        else
          Rails.logger.debug("更新対象なし（#{mall_key}-#{site_key}）")
        end
      end
    end
  end

  # 在庫更新データを共有ディレクトリに配置する
  def post_stock_file(filelist, mall_key, site_key)
    share_dir = "#{FileConstants::SHARE_DIR}#{File::SEPARATOR}#{mall_key}#{File::SEPARATOR}#{site_key}"
    FileUtils::mkdir_p(share_dir) unless Dir.exist?(share_dir)
    filelist = sort_post_stock_file(filelist, mall_key, site_key)
    filelist.each do |filepath|
      upload_filename = get_upload_filename(filepath, mall_key, site_key)

      count = 0
      while true
        tmp_filename = count > 0 ? "#{upload_filename}.#{"%03d" % count}" : upload_filename
        upload_filepath = "#{share_dir}#{File::SEPARATOR}#{tmp_filename}"
        count += 1
        break unless File.exist?(upload_filepath)
      end

      Rails.logger.debug("post to share folder #{File.basename(filepath)} → #{File.basename(upload_filepath)}")
      FileUtils.cp(filepath, upload_filepath)
    end
  end

  # 更新ファイルの出力順をソートする
  def sort_post_stock_file(filelist, mall_key, site_key)
    new_filelist = Array.new()
    filelist.each do |filepath|
      basename = File.basename(filepath).gsub("#{mall_key}_#{site_key}_", "")
      # 選択肢更新(削除)ファイルがあれば、新しいファイルリストに格納する
      if basename.to_s == MallConstants::OPTION_DELETE_FILENAME then
        new_filelist << filepath
        filelist.delete(filepath)
      end
      # 選択肢更新(登録)ファイルがあれば、新しいファイルリストに格納する
      if basename.to_s == MallConstants::OPTION_FILENAME then
        new_filelist << filepath
        filelist.delete(filepath)
      end
    end
    # ファイルリストに残っているファイルパスを、新しいファイルリストの後ろに結合する
    new_filelist.concat(filelist)

    return new_filelist
  end

  # アップロードするファイル名を取得する
  def get_upload_filename(filepath, mall_key, site_key)
    filename = nil
    basename = basename = File.basename(filepath).gsub("#{mall_key}_#{site_key}_", "")
    "MallConstants::#{mall_key.camelize}::FILE_NAME".constantize[basename]
  end

  # アップロードしたファイルをバックアップする
  def backup_upload_file()
    # バックアップ対象のファイルリストを取得
    filelist = Array.new()
    Dir.glob("#{@@upload_dir}#{File::SEPARATOR}*").each do |filepath|
      filelist.push(filepath) if File.file?(filepath)
    end
    return unless filelist.size > 0
    backup_dir = "#{File.dirname(@@upload_dir)}#{File::SEPARATOR}#{FileConstants::BACKUP_DIR_NAME}"
    FileUtils::mkdir_p(backup_dir) unless Dir.exist?(backup_dir)

    arc_filename = "#{FileConstants::UPLOAD_ARCHIVE_FILENAME}_#{Time.now.strftime("%Y%m%d%H%M%S")}.zip"
    arc_filepath = backup_dir + File::SEPARATOR + arc_filename
    Utils::FileUtil.archive_file(arc_filepath, filelist)

    filelist.each do |filepath|
      File.delete(filepath)
    end

    return arc_filepath
  end

end