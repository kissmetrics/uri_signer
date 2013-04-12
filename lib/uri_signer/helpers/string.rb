require 'uri'
require 'cgi'
require 'rack/utils'
require 'base64'
require 'hmac'
require 'hmac-sha2'
require 'addressable/uri'

module UriSigner
  module Helpers
    module String
      # Returns the string with newlines replaced with <br>
      #
      # @return [String] HTML version
      def nl2br
        self.gsub(/\n/, '<br>')
      end

      # This returns the string Base64 encoded with the newlines removed
      #
      # @return [String] encoded
      def base64_encoded
        Base64.encode64(self).chomp
      end

      # This delegates the call to Rack::Utils to escape a string
      #
      # @return [String] escaped
      def escaped
        return '' if self.nil?
        unescaped = URI.unescape(self) # This will fix the percent encoding issue
        Rack::Utils.escape(unescaped)
      end

      # This delegates the call to Rack::Utils to unescape a string
      #
      # @return [String] unescaped
      def unescaped
        Rack::Utils.unescape(self)
      end

      # Digitally sign a string with a secret and get the digest
      #
      # @return [String]
      def hmac_signed_with(secret)
        hmac = HMAC::SHA256.new(secret)
        hmac << self
        hmac.digest
      end

      # Take a URL string and convert it to a URI Parsed object
      #
      # @return [Addressable]
      def to_parsed_uri
        Addressable::URI.parse(CGI.unescapeHTML(self))
      end
    end
  end
end
