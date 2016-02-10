require 'openssl'
require 'uri'
require 'cgi'
require 'base64'

module SignedApiRequest
  class << self
    attr_accessor :encoder

    def configure
      self.encoder ||= UidsEncoder.new
      yield(encoder)
    end

    def generate(uids:, expires:)
      encoder.encode(uids: uids, expires: expires)
    end

    def validate(key_id:, secret:, uids:, expires:, signature:)
      validating_encoder = UidsEncoder.new
      validating_encoder.key_id = key_id
      validating_encoder.secret = secret
      signature_matched = (signature == CGI.unescape(validating_encoder.encode(uids: uids, expires: expires)))
      time_in_the_future = Time.at(expires.to_i).utc > Time.now.utc
      signature_matched && time_in_the_future
    end
  end

  class UidsEncoder
    attr_accessor :key_id, :secret

    def encode(uids:, expires:)
      signature(expires.to_i, uids)
    end

    private

    def signature(expires, uids)
      digest = OpenSSL::Digest.new('sha256')
      hmac = OpenSSL::HMAC.digest(digest, @secret, "GET\n\n\n#{expires}\n/#{uids.join(',')}")
      CGI.escape(URI.escape(Base64.encode64(hmac).strip))
    end
  end
end
