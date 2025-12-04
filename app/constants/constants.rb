module  Constants
  

  MAX_CODE_COUNT = 50000

  # 実行モード
  DEBUG = 0
  RELEASE = 1

  # 在庫表ダウンロード元
  FILE_SOURCE_MAIL = "mail"
  FILE_SOURCE_WEB = "web"

  # 在庫表フォーマット
  FILE_EXT_CSV = "CSV"
  FILE_EXT_EXCEL = "Excel"

  # 在庫表ヘッダー
  CODE = :code
  SKU_CODE = :sku_code
  STOCK = :stock
  DELIVERY_DATE = :delivery_date
  DELIVERY_NUM = :delivery_num
  LEADTIME_NUM = :leadtime_num
  OPTION_KEY = :option_key
  OPTION_VALUE = :option_value
  OPTION_H_ID = :option_h_id
  OPTION_H = :option_h
  OPTION_V_ID = :option_v_id
  OPTION_V = :option_v
  EXTRA1  = :param_1
  EXTRA2  = :param_2
  EXTRA3  = :param_3

  # AWS S3
  AWS_DEFAULT_REGION = "ap-northeast-1"
  AWS_ACCESS_KEY_ID = ""
  AWS_SECRET_ACCESS_KEY = ""
  S3_BUCKET_NAME = EasySettings.aws.s3_bucket_name
  S3_STORAGE_PATH = "mailbox/stock"

  # WebDriver Setting
  BROWSER_TYPE_CHROME = "chrome"
  BROWSER_TYPE_FIREFOX = "firefox"
  DEFAULT_BROWSER_TYPE = BROWSER_TYPE_CHROME
  CHROME_PATH = "C:/Program Files (x86)/chrome-win32/chrome.exe"
  CHROME_TEMP_FILE_EXT = ".crdownload"
  BROWSER_TIMEOUT = 300 #seconds
  DOWNLOAD_CHECK_SPAN = 5

  UPDATE_LIMIT_STOCK = 900
  OUTPUT_LIMIT_STOCK = 300

end