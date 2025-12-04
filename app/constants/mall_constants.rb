module MallConstants
  
  ITEM_STOCK_FILENAME = "item.csv"
  SKU_STOCK_FILENAME = "sku.csv"
  OPTION_FILENAME = "option.csv"
  OPTION_DELETE_FILENAME = "option_delete.csv"
  LEADTIME_FILENAME = "lead_time.csv"

  module Rakuten
    HEADER = {
      ITEM_STOCK_FILENAME => ["商品管理番号（商品URL）", "SKU管理番号", "在庫数", "在庫あり時納期管理番号", "在庫あり時出荷リードタイム"],
      SKU_STOCK_FILENAME => ["商品管理番号（商品URL）", "SKU管理番号", "在庫数", "在庫あり時納期管理番号", "在庫あり時出荷リードタイム"],
      OPTION_FILENAME => ["商品管理番号（商品URL）","選択肢タイプ","商品オプション項目名"].concat(Array.new(100) {|i| "商品オプション選択肢#{i+1}"}).push("商品オプション選択必須"),
      OPTION_DELETE_FILENAME => ["商品管理番号（商品URL）","選択肢タイプ","商品オプション項目名"]
    }
    FILE_NAME = {
      ITEM_STOCK_FILENAME => "normal-item.csv",
      SKU_STOCK_FILENAME => "normal-item.csv",
      OPTION_FILENAME => "normal-item.csv",
      OPTION_DELETE_FILENAME => "item-delete.csv"
    }
  end
  
  module Yahoo
    HEADER = {
      ITEM_STOCK_FILENAME => ["code", "sub-code", "quantity"],
      SKU_STOCK_FILENAME => ["code", "sub-code", "quantity"],
      OPTION_FILENAME => ["code","sub-code","name","option-name-1","option-value-1","spec-id-1","spec-value-id-1","option-name-2","option-value-2","spec-id-2","spec-value-id-2","etc-options","lead-time-instock","lead-time-outstock","sub-code-img1","main-flag","exist-flag"],
      OPTION_DELETE_FILENAME => ["code","options"],
      LEADTIME_FILENAME => ["code", "lead-time-instock"]
    }
    FILE_NAME = {
      ITEM_STOCK_FILENAME => "quantity_item.csv",
      SKU_STOCK_FILENAME => "quantity_sku.csv",
      OPTION_FILENAME => "option_add_add.csv",
      OPTION_DELETE_FILENAME => "data_spy_option.csv",
      LEADTIME_FILENAME => "data_spy_lead_time.csv"
    }
  end
  
  module Wowma
    HEADER = {
      ITEM_STOCK_FILENAME => ["ctrlCol", "lotNumber", "saleStatus", "stockCount", "stockShippingDayId"],
      SKU_STOCK_FILENAME => ["ctrlCol", "lotNumber", "stockSegment", "saleStatus", "choicesStockHorizontalCode", "choicesStockVerticalCode", "choicesStockCount", "choicesStockShippingDayId"],
      OPTION_FILENAME => ["ctrlCol", "lotNumber", "itemOption1", "itemOption2", "itemOption3", "itemOption4", "itemOption5", "itemOption6", "itemOption7", "itemOption8", "itemOption9", "itemOption10", "itemOption11", "itemOption12", "itemOption13", "itemOption14", "itemOption15", "itemOption16", "itemOption17", "itemOption18", "itemOption19", "itemOption20"]
    }
    FILE_NAME = {
      ITEM_STOCK_FILENAME => "item.csv",
      SKU_STOCK_FILENAME => "stock.csv",
      OPTION_FILENAME => "item.csv"
    }
  end
  
  module Amazon
    HEADER = {
      ITEM_STOCK_FILENAME => [
        ["TemplateType=PriceInventory","Version=2018.0924","この行はAmazonが使用しますので変更や削除しないでください。",nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil],
        ["商品管理番号","販売価格","ポイント","在庫数","通貨コード","セール価格","セール時ポイントパーセント","セール開始日","セール終了日","商品の入荷予定日","販売価格の下限設定","販売価格の上限設定","出荷経路","出荷作業日数"],
        ["sku","price",nil,"quantity","currency","sale-price","sale-price-points-percent","sale-from-date","sale-through-date","restock-date","minimum-seller-allowed-price","maximum-seller-allowed-price","fulfillment-channel","handling-time"]
      ]
    }
    FILE_NAME = {
      ITEM_STOCK_FILENAME => "item.tsv"
    }
  end
  module Kaago
    HEADER = {
      ITEM_STOCK_FILENAME => ["SKUCD", "StockQuantity", "CategoryCD", "ArrangementTime"]
    }
    FILE_NAME = {
      ITEM_STOCK_FILENAME => "stock.csv"
    }
  end
  
  module Qoo10
    HEADER = {
      ITEM_STOCK_FILENAME => ["Item Code", "Seller Code", "Sell Qty"],
      SKU_STOCK_FILENAME => ["Item Code", "Seller Code", "Option Name", "Option Value", "Option Code", "Price", "Qty"],
      OPTION_FILENAME => ["Item Code", "Seller Code", "Option Info"]
    }
    FILE_NAME = {
      ITEM_STOCK_FILENAME => "stock.csv",
      SKU_STOCK_FILENAME => "inventory.csv",
      OPTION_FILENAME => "option_info.csv"
    }
  end
  
  module Shopify
    HEADER = {
      ITEM_STOCK_FILENAME => ['inventory_item_id', 'available', 'handle'],
      SKU_STOCK_FILENAME => ['inventory_item_id', 'available', 'handle'],
      LEADTIME_FILENAME => ['product_id', 'variant_id', 'metafield_leadtime_id', 'leadtime', 'handle']
    }
    FILE_NAME = {
      ITEM_STOCK_FILENAME => "stock.csv",
      SKU_STOCK_FILENAME => "stock.csv",
      LEADTIME_FILENAME => "inventory.csv"
    }
  end
  
  module Eccube
    HEADER = {
      ITEM_STOCK_FILENAME => ['商品管理番号', '規格分類1(名称)', '規格分類2(名称)', '在庫数', '発送日目安(ID)'],
      SKU_STOCK_FILENAME => ['商品管理番号', '規格分類1(名称)', '規格分類2(名称)', '在庫数', '発送日目安(ID)'],
      OPTION_FILENAME => ['商品管理番号', 'オプション項目名', 'オプション選択肢名']
    }
    FILE_NAME = {
      ITEM_STOCK_FILENAME => "item.csv",
      SKU_STOCK_FILENAME => "sku_item.csv",
      LEADTIME_FILENAME => "option.csv"
    }
  end

  module Base
    HEADER = {
      ITEM_STOCK_FILENAME => ['item_id', 'stock', 'identifier'],
      SKU_STOCK_FILENAME => ['item_id', 'variation_id', 'variation_stock', 'variation_identifier']
    }
    FILE_NAME = {
      ITEM_STOCK_FILENAME => "item.csv",
      SKU_STOCK_FILENAME => "stock.csv",
    }
  end

  module Linemall
    HEADER = {
      ITEM_STOCK_FILENAME => ['バリエーションコード', '在庫数'],
      SKU_STOCK_FILENAME => ['バリエーションコード', '在庫数']
    }
    FILE_NAME = {
      ITEM_STOCK_FILENAME => "stock.csv",
      SKU_STOCK_FILENAME => "stock.csv"
    }
  end

  module Roomclip
    HEADER = {
      ITEM_STOCK_FILENAME => ['種類別の自社管理コード', '在庫数']
    }
    FILE_NAME = {
      ITEM_STOCK_FILENAME => "stock.csv"
    }
  end

  module Yaichi
    HEADER = {
      ITEM_STOCK_FILENAME => ['master_sku', 'sku', 'stock', 'delivery_lead_time_id'],
      SKU_STOCK_FILENAME => ['master_sku', 'sku', 'stock', 'delivery_lead_time_id']
    }
    FILE_NAME = {
      ITEM_STOCK_FILENAME => "stock.csv",
      SKU_STOCK_FILENAME => "stock.csv"
    }
  end

  module Dshopping
    HEADER = {
      SKU_STOCK_FILENAME => ['SKU', '数量']
    }
    FILE_NAME = {
      SKU_STOCK_FILENAME => "stock.csv"
    }
  end

  module Giftmall
    HEADER = {
      ITEM_STOCK_FILENAME => ['product_code', 'quantity'],
      SKU_STOCK_FILENAME => ['product_code', 'quantity']
    }
    FILE_NAME = {
      ITEM_STOCK_FILENAME => "stock.csv",
      SKU_STOCK_FILENAME => "stock.csv"
    }
  end

  module Anamall
    HEADER = {
      ITEM_STOCK_FILENAME => ['SKUコード', '在庫数量']
    }
    FILE_NAME = {
      ITEM_STOCK_FILENAME => "stock.csv"
    }
  end
  
  module StoreeSaison
    HEADER = {
      ITEM_STOCK_FILENAME => ['商品コード', '在庫数']
    }
    FILE_NAME = {
      ITEM_STOCK_FILENAME => "stock.csv"
    }
  end

end 
  