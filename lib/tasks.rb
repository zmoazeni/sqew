namespace :sqew do
  desc "Start a worker"
  task :work => :environment do
    Sqew::Manager.new.start
  end
end

# Convenience tasks compatibility
task 'jobs:work'   => 'sqew:work'
task 'resque:work' => 'sqew:work'

# No-op task in case it doesn't already exist
task :environment
