class Common::OutputStockService < Common::ApplicationService

  def call()
    Rails.logger.debug("start:#{self.class.to_s}")
    begin
      mall_masters = MasterMall.all
      mall_masters.each do |mall_master|
        # モールごとに出力用クラスを呼び出す
        mall_key = mall_master.key
        output_service = "Mall::#{mall_key.camelize}::OutputService".classify.constantize.new() rescue next
        # モールごとの出力データを抽出
        mall_updated_parsers = @@updated_parsers.select{|item_parser| item_parser.mall_key == mall_key}
        next if mall_updated_parsers.size == 0
        # 出力用クラスを実行
        output_service.call(mall_updated_parsers, mall_master)
      end
    rescue => ex
      output_exception(ex)
      raise OutputStockException.new()
    end
    Rails.logger.debug("end:#{self.class.to_s}")
  end
  
end