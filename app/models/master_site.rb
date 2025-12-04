class MasterSite < ApplicationRecord
  belongs_to :master_mall, foreign_key: :mall_master_id

  has_many :pmg_items, foreign_key: :site_master_id
  has_many :pmg_skus, foreign_key: :site_master_id
end