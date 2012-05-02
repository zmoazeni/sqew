require "sqew"

Sqew.configure do |c|
  c.logger = Logger.new(STDOUT)
  c.logger.level = Logger::INFO
end

if defined?(Rails)
  if defined?(Rails::Railtie)
    require 'sqew/railtie'
  else
    Sqew.logger = Rails.logger
  end
end
