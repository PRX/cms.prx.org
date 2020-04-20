PrxAuth::Rails.configure do |config|
  config.install_middleware = ENV['ID_HOST'].blank?
  config.namespace = :cms
end