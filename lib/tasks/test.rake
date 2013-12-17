# this is only temporary as we use the existing prx db in read-only mode
# eventually, don't do this.

Rake.application.remove_task 'db:test:prepare'
Rake.application.remove_task 'db:test:load'
Rake.application.remove_task 'db:test:load_schema'
Rake.application.remove_task 'db:test:purge'

namespace :db do

  namespace :test do

    task :prepare do |t|
      # puts 'prepare!'
    end

    task :load do |t|
      # puts 'load!'
    end

    task :load_schema do |t|
      # puts 'load_schema!'
    end

    task :purge do |t|
      # puts 'purge!'
    end

  end
end

