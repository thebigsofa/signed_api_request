require 'openssl'
require 'uri'
require 'cgi'
require 'base64'

module SignedApiRequest
  class << self
    attr_accessor :encoder

    def configure
      self.encoder ||= GuidsEncoder.new
      yield(encoder)
    end

    def generate(guids:, expires:)
      encoder.encode(guids: guids, expires: expires)
    end

    def validate(key_id:, secret:, guids:, expires:, signature:)
      validating_encoder = GuidsEncoder.new
      validating_encoder.key_id = key_id
      validating_encoder.secret = secret
      signature_matched = (signature == CGI.unescape(validating_encoder.encode(guids: guids, expires: expires)))
      time_in_the_future = Time.at(expires.to_i).utc > Time.now.utc
      signature_matched && time_in_the_future
    end
  end

  class GuidsEncoder
    attr_accessor :key_id, :secret

    def encode(guids:, expires:)
      signature(expires.to_i, guids)
    end

    private

    def signature(expires, guids)
      digest = OpenSSL::Digest.new('sha256')
      hmac = OpenSSL::HMAC.digest(digest, @secret, "GET\n\n\n#{expires}\n/#{guids.join(',')}")
      CGI.escape(URI.escape(Base64.encode64(hmac).strip))
    end
  end
end
