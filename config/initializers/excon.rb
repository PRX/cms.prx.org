require 'excon'

Excon.defaults[:omit_default_port] = true
Excon.defaults[:ssl_ca_path] = ENV['CERT_PATH'] if ENV['CERT_PATH']
