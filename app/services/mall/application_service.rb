class Mall::ApplicationService < ApplicationService

  def initialize()
  end

  def get_mall_name()
    self.class.to_s.slice(/Mall::(.+)::/, 1)
  end
  
end