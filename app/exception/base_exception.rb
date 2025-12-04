class BaseException < StandardError

  attr_accessor :level

  def initialize(message = nil, level = nil)
    super(message)
    @level = level
  end
  
end