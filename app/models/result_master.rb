class ResultMaster < ActiveYaml::Base
  include ActiveHash::Enum
  
  set_root_path "config/masters"
  set_filename "result_master"

  enum_accessor :type

end
