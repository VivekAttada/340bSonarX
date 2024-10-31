require 'jwt'
require 'openssl'

class JWTUtils
  ALGORITHM = 'RS256'
  PUBLIC_KEY = OpenSSL::PKey::RSA.new(File.read('keys/jwt_public_key.pem'))

  def self.validate_token(token)
    JWT.decode(token, PUBLIC_KEY, true, { algorithm: ALGORITHM }).first
  end
end