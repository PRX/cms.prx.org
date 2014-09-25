class ValidateAuthorizationHeader
  attr_reader :public_key

  def initialize(app)
    @app = app
    @public_key = PublicKey.new
  end

  def call(env)
    if env['HTTP_AUTHORIZATION'] =~ /\ABearer/
        token = env['HTTP_AUTHORIZATION'].split[1]
      begin
        claims = JSON::JWT.decode(token, @public_key.key)
      rescue JSON::JWT::VerificationFailed => e
        [401, {'Content-Type' => 'application/json'}, [{status: 401, error: 'Invalid JSON Web Token'}.to_json]]
      else
        env['prx.auth'] = claims

        @app.call(env)
      end
    else
      @app.call(env)
    end
  end

  class PublicKey
    EXPIRES_IN = 12.hours
    AUTH_URI = URI('https://auth.prx.org/api/v1/certs')

    def initialize
      @created_at = Time.now
      get_key
    end

    def refresh_key
      if Time.now > @created_at + EXPIRES_IN
        get_key
      end
    end

    def get_key
      certs = JSON.parse(Net::HTTP.get(AUTH_URI))
      cert_string = certs["certificates"].values[0]
      certificate = OpenSSL::X509::Certificate.new(cert_string)
      @key = certificate.public_key
    end

    def key
      refresh_key
      @key
    end
  end
end
