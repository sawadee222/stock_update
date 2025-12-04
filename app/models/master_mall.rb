class MasterMall < ApplicationRecord
  has_many :master_sites, foreign_key: :mall_master_id

end