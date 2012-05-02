module Sqew
  class Railtie < Rails::Railtie
    rake_tasks do
      load "sqew/tasks.rb"
    end

    initializer "sqew.logger" do |app|
      Sqew.logger = Rails.logger
    end
  end
end
