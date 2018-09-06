class ElasticsearchHelper
  # we use the same 9200 server docker instance, but with "-test" suffix on each index name.
  def create_es_index(klass)
    unless klass.index_name.match /-test$/
      klass.index_name klass.index_name + '-test'
    end
    debug { "Rebuilding index for #{klass}..." }
    search = klass.__elasticsearch__
    _create search, name: klass.index_name
    _import search
    _refresh search
  end

  def _create(search, name: nil)
    debug { '  Creating index...' }
    search.create_index!(
      # Req'd by https://github.com/elastic/elasticsearch-rails/issues/571
      force: search.index_exists?(index: name),
      index: name
    )
  end

  def _import(search)
    debug { '  Importing data...' }
    search.import(return: "errors", batch_size: 200) do |resp|
      errors    = resp["items"].select { |k, _v| k.values.first["error"] }
      completed = resp["items"].size
      debug { "Finished #{completed} items" }
      debug { "ERRORS in #{$PROCESS_ID}: #{errors.pretty_inspect}" } unless errors.empty?
      [STDOUT, STDERR].each(&:flush)
    end
  end

  def _refresh(search)
    debug { '  Refreshing index...' }
    search.refresh_index!
  end

  def debug
    if ENV['ES_DEBUG']
      puts yield
    end
  end

  # create test indices.
  def self.es_setup
    helper = new
    [User, Series, Story, StationAccount, GroupAccount, Playlist].each do |klass|
      helper.create_es_index(klass)
    end
  rescue Faraday::ConnectionFailed => e
    puts "WARN: No elasticsearch connection"
  end
end
