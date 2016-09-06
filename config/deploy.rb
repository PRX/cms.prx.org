# config valid only for Capistrano 3.2
lock '~> 3.2'

require 'dotenv'
Dotenv.load

set :application, 'cms.prx.org'
set :repo_url, 'git://github.com/PRX/cms.prx.org'

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }

# Default deploy_to directory is /var/www/my_app
set :deploy_to, '/var/www/domains/prx.org/hal'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
set :linked_files, %w{ .env }

# Default value for linked_dirs is []
set :linked_dirs, %w{ log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# Default value for default_env is {}
set :default_env, { path: "/opt/ruby/ruby-2.1.1/bin:$PATH" }

# Default value for keep_releases is 5
set :keep_releases, 5

namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  desc 'Start/restart worker'
  task :worker do
    on roles(:app), in: :sequence, wait: 5 do
      within release_path do
        with rails_env: fetch(:rails_env) do
          log = release_path.join('log/production.worker.log')
          pid = release_path.join('tmp/pids/production.worker.pid')
          opts = "-al #{log} -c /bin/sh --pidFile #{pid} --workingDir #{release_path}"

          # stop any running worker
          execute :forever, :stop, "$(cat #{pid})" if test("[ -f #{pid} ]")
          execute :forever, :start, opts, 'bin/application worker'
        end
      end
    end
  end

  after :publishing, :restart
  after :restart, :worker

  desc "Flushes cache"
  task :flush_cache do
    on roles(:app) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :rake, 'cache:flush'
        end
      end
    end
  end

  # not sure we always want to flush the cache
  # after :restart, :flush_cache

end
