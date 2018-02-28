# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

PRX::Application.load_tasks

Rails::TestTask.new('test:representers' => 'test:prepare') do |t|
  t.pattern = 'test/representers/**/*_test.rb'
end

Rails::TestTask.new('test:uploaders' => 'test:prepare') do |t|
  t.pattern = 'test/uploaders/**/*_test.rb'
end

Rake::Task['test:run'].enhance ['test:representers', 'test:uploaders']
