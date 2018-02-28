require 'fileutils'

namespace :db do

  PROD_SSH = 'deploy@cms.prx.org'.freeze
  PROD_ENV = '/var/www/domains/prx.org/hal/current/.env'.freeze
  IGNORE_TABLES = %w(
    audio_file_listenings
    feed_items
    feed_items_archive
    message_receptions
    messages
    published_feed_items
    site_message_receptions
    say_when_job_executions
    say_when_jobs
    oauth_nonces
    oauth_tokens
    open_id_associations
    open_id_nonces
    deliveries
    delivery_logs
    audio_file_deliveries
    alerts
    client_applications
  ).freeze

  desc 'Dump production data to backup files'
  task :proddump do
    puts 'Running mysqldump...'

    stamp = Time.now.strftime('%Y%m%d')
    out_struct = "#{stamp}_${DB_ENV_MYSQL_DATABASE}_structure.sql.gz"
    out_data = "#{stamp}_${DB_ENV_MYSQL_DATABASE}_data.sql.gz"
    parms = '--user=$DB_ENV_MYSQL_USER --password=$DB_ENV_MYSQL_PASSWORD $DB_ENV_MYSQL_DATABASE'
    ignores = IGNORE_TABLES.map { |tbl| "--ignore-table=${DB_ENV_MYSQL_DATABASE}.#{tbl}" }.join(' ')

    puts "  dumping structure #{stamp}..."
    out = `ssh #{PROD_SSH} 'source #{PROD_ENV} && mysqldump #{parms} --no-data | gzip > #{out_struct}'`
    exit $?.exitstatus unless $?.success?

    puts "  dumping data #{stamp}..."
    out = `ssh #{PROD_SSH} 'source #{PROD_ENV} && mysqldump #{parms} #{ignores} | gzip > #{out_data}'`
    exit $?.exitstatus unless $?.success?

    puts 'Done!'
  end

  desc 'Copy the latest prod backup to your local filesystem'
  task :prodcopy do
    puts 'Checking for existing backups...'

    out = `ssh #{PROD_SSH} 'ls'`
    exit $?.exitstatus unless $?.success?

    backups = out.split("\n").select { |name| name =~ /mediajoint_production(_data|_structure).sql.gz/ }.sort
    backups.each do |name|
      puts "  #{name}"
    end

    latest_structure = backups[-1]
    latest_data = backups[-2]
    abort 'No backups found! Run rake db:proddump first.' if backups.empty?
    abort 'No structure found for latest backup!' unless latest_structure =~ /_structure/
    abort 'No data found for latest backup!' unless latest_data =~ /_data/
    abort 'No data found for latest backup!' unless latest_structure.split('_').first == latest_data.split('_').first
    puts ''

    print "Copying backup from #{latest_data.split('_').first}"
    FileUtils.mkdir_p('tmp/dbbootstrap')
    puts '  copying structure...'
    `scp #{PROD_SSH}:~/#{latest_structure} tmp/dbbootstrap/`
    exit $?.exitstatus unless $?.success?
    puts '  copying data...'
    `scp #{PROD_SSH}:~/#{latest_data} tmp/dbbootstrap/`
    exit $?.exitstatus unless $?.success?

    puts 'Done!'
  end

  desc 'Bootstrap production data into your current database'
  task :bootstrap do
    abort "You shouldn't run this in prod" if Rails.env.production?
    puts 'Checking locally for backups...'

    out = `ls tmp/dbbootstrap`
    exit $?.exitstatus unless $?.success?

    backups = out.split("\n").select { |name| name =~ /mediajoint_production(_data|_structure).sql.gz/ }.sort
    latest_structure = backups[-1]
    latest_data = backups[-2]
    abort 'No backups found! Run rake db:prodcopy first.' if backups.empty?
    abort 'No structure found for latest backup!' unless latest_structure =~ /_structure/
    abort 'No data found for latest backup!' unless latest_data =~ /_data/
    abort 'No data found for latest backup!' unless latest_structure.split('_').first == latest_data.split('_').first
    puts "  found #{latest_data}"

    db_name = ENV['DB_ENV_MYSQL_DATABASE']
    db_name = 'cms_development' if Rails.env.development?
    db_name = 'cms_test' if Rails.env.test?
    db_host = ENV['DB_PORT_3306_TCP_ADDR']
    db_user = ENV['DB_ENV_MYSQL_USER']
    db_pass = ENV['DB_ENV_MYSQL_PASSWORD']

    parms = "--host=#{db_host} #{db_name}"
    parms = if db_host == 'db'
              "--user=root #{parms}"
            else
              "--user=#{db_user} --password=#{db_pass} #{parms}"
            end

    puts 'Restoring from backup'
    puts '  overwriting structure...'
    `gunzip < tmp/dbbootstrap/#{latest_structure} | mysql #{parms}`
    exit $?.exitstatus unless $?.success?

    puts '  overwriting data...'
    `gunzip < tmp/dbbootstrap/#{latest_data} | mysql #{parms}`
    exit $?.exitstatus unless $?.success?

    puts 'Done!'
  end

end
