require 'excon'

Excon.defaults[:omit_default_port] = true
Excon.defaults[:ssl_ca_file] = ENV['CERT_FILE'] if ENV['CERT_FILE']
