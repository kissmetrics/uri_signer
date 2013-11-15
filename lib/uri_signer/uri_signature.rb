module UriSigner
  # This is the object that will be used to verify properly signed API URI requests
  # The #secret is stored in the persistence layer for comparison. There is an API Key
  # and a shared secret. All requests will be signed with the shared secret. The URI
  # will also include a _signature param, where the client will sign the request and
  # store it in the URI.
  #
  # The signing algorithm looks like this:
  #
  # @example
  #   secret = "my_secret"
  #   string_to_sign = "http://api.example.com/url/to_sign.json"
  #
  #   hmac = HMAC::SHA256.new(secret)
  #
  #   hmac.digest
  #   # => "??B\230????șo\271$'\256A?d?\223L\244\225\231\exR\270U"
  #
  #   hmac << string_to_sign
  #
  #   hmac.digest
  #   # => "?m?j\2761\031\235\206\260?A?\f\263\216\221\fBH?fC\215Ļ\204\233\202@/e"
  #
  #   encoded = Base64.encode64(hmac.digest).chomp
  #   # => "8W3xar4xGZ2GsOJBmAyzjpEMQkg/ZkONxLuEm4JAL2U="
  #
  #   escaped = Rack::Utils.escape(encoded)
  #   # => "8W3xar4xGZ2GsOJBmAyzjpEMQkg%2FZkONxLuEm4JAL2U%3D"
  #
  #   # The final signed string is "8W3xar4xGZ2GsOJBmAyzjpEMQkg%2FZkONxLuEm4JAL2U%3D"
  #
  class UriSignature
    # Create a new UriSignature instance
    #
    # @param signature_string [String] the string that needs to be signed
    # @param secret [String] the secret to use for the signature
    #
    # @return [void]
    def initialize(signature_string, secret)
      @signature_string = signature_string
      @secret           = secret

      raise UriSigner::Errors::MissingSignatureStringError.new("Please provide a string to sign") unless signature_string?
      raise UriSigner::Errors::MissingSecretError.new("Please provide a secret to sign the string") unless secret?
    end

    # Return the signature string that was provided in the constructor
    #
    # @return [String]
    def signature_string
      @signature_string
    end

    # Return the signature_string after being signed with the secret
    #
    # @return [String]
    def signature
      @signature ||= sign!
    end
    alias :to_s :signature

    private
    def signature_string?
      !@signature_string.blank?
    end

    def secret?
      !@secret.blank?
    end

    def sign!
      extension = UriSigner::Helpers::String

      hmac = self.signature_string.extend(extension).hmac_signed_with(@secret)
      hmac.extend(extension).base64_encoded
    end
  end
end
