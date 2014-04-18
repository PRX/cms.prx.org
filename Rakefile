# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

begin; require 'minitest/rails/testing'; rescue LoadError; end
if defined?(MiniTest::Rails::Testing)
  MiniTest::Rails::Testing.default_tasks << 'representers' << 'uploaders'
end

PRX::Application.load_tasks
