Rails.autoloaders.each do |autoloader|
  autoloader.inflector.inflect(
    "4t" => "At",
  )
end