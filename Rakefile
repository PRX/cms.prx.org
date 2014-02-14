# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

PRX::Application.load_tasks

namespace :test do
  task :coverage do
    require 'simplecov'
    SimpleCov.command_name 'minitest:all'
    Rake::Task["minitest:all"].execute
  end
end

task(:default).clear.enhance ['test:coverage']
