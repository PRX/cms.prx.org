require 'elasticsearch/model'

# defaults
es_client_args = {
  transport_options: {
    request: {
      timeout: 1 * 60,
      open_timeout: 1 * 60
    }
  },
  retry_on_failure: 5,
  url: ENV.fetch('ELASTICSEARCH_URL', 'http://elasticsearch:9200')
}

if Rails.env.test?
# necessary if we use the test ES features.
#  es_client_args[:url] = "http://elasticsearch:#{(ENV['TEST_CLUSTER_PORT'] || 9250)}"
end

# optional verbose logging based on env var, regardless of environment.
if ENV['ES_DEBUG']
  logger = Logger.new(STDOUT)
  logger.level = Logger::DEBUG
  tracer = Logger.new(STDERR)
  tracer.formatter = ->(_s, _d, _p, m) { "#{m.gsub(/^.*$/) { |n| '   ' + n }}\n" }
  es_client_args[:log] = true
  es_client_args[:logger] = logger
  es_client_args[:tracer] = tracer
  logger.debug "[#{Time.now.utc.iso8601}] Elasticsearch logging set to DEBUG mode"
end

Elasticsearch::Model.client = Elasticsearch::Client.new(es_client_args)

if ENV['ES_DEBUG']
  es_client_args[:logger].debug "[#{Time.now.utc.iso8601}] Using Elasticsearch server #{es_client_args[:url]}"
end
