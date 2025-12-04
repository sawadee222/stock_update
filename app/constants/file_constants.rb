module FileConstants

  SP = File::SEPARATOR

  COMMON_DIR = File.expand_path('../..', File.dirname(__FILE__))

  # Path
  DOWNLOAD_DIR = COMMON_DIR + SP + "download"
  MASTER_DIR = COMMON_DIR + SP + "master"
  SHARE_DIR = COMMON_DIR + SP + "share"
  UPLOAD_DIR = COMMON_DIR + SP + "upload"
  PUBLIC_DIR = COMMON_DIR + SP + "public"

  OS_DOWNLOAD_DIR = "C:/Users/hoge/Downloads"
  FTP_TOOL_DIR = COMMON_DIR + SP + "share/FTPToolUser"
  FTP_TOOL_USER_DIR = FTP_TOOL_DIR + SP + "user8"

  # File Name
  BACKUP_DIR_NAME = "backup"
  UPLOAD_ARCHIVE_FILENAME = "uploaded"

  # Option Stop Flag
  OPTION_STOP_FILENAME = "option_stop.flg"
  OPTION_STOP_FLAG = COMMON_DIR + SP + OPTION_STOP_FILENAME
end