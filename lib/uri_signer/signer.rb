module UriSigner
  # This is the object that wraps the other building blocks and can be used to sign requests. 
  #
  # @example
  #   http_method = "get"
  #   uri         = "https://api.example.com/core/people.json?page=5&per_page=25&order=name:desc&select=id,name"
  #   secret      = "my_secret"
  #
  #   signer = UriSigner::Signer.new(http_method, uri, secret)
  #
  #   signer.http_method
  #   # => "GET"
  #
  #   signer.uri
  #   # => "https://api.example.com/core/people.json?page=5&per_page=25&order=name:desc&select=id,name"
  #
  #   signer.signature
  #   # => "1AaJvChjz%2BZYJKxWsUQWNK1a%2BeGjpCs6uwQKwPw1%2FV8%3D"
  #
  #   signer.uri_with_signature
  #   # => "https://api.example.com/core/people.json?_signature=6G4xiABih7FGvjwB1JsYXoeETtBCOdshIu93X1hltzk%3D"
  #
  #   signer.valid?("1AaJvChjz%2BZYJKxWsUQWNK1a%2BeGjpCs6uwQKwPw1%2FV8%3D")
  #   # => true
  #
  #   signer.valid?('1234')
  #   # => false
  #
  class Signer
    # Create a new UriSigner instance
    #
    # @param http_method [String] The HTTP method used to make the request (GET, POST, PUT, and DELETE)
    # @param uri [String] The requested URI
    # @param secret [String] The secret that is used to sign the request
    #
    # @return [void]
    def initialize(http_method, uri, secret)
      @http_method = http_method
      @uri         = uri
      @secret      = secret

      raise UriSigner::Errors::MissingHttpMethodError.new("Please provide an HTTP method") unless http_method?
      raise UriSigner::Errors::MissingUriError.new("Please provide a URI") unless uri?
      raise UriSigner::Errors::MissingSecretError.new("Please provide a secret to sign the string") unless secret?
    end

    # Returns the URI passed into the constructor
    #
    # @return [String]
    def uri
      @uri
    end

    # Returns the URI with the signature appended to the query string
    #
    # return [String]
    def uri_with_signature
      separator = if request_parser.query_params? then '&' else '?' end
      "%s%s_signature=%s" % [self.uri, separator, self.signature]
    end

    # Returns the uppercased HTTP Method
    #
    # @return [String]
    def http_method
      @http_method.to_s.upcase
    end

    # Returns the signature
    #
    # @return [String]
    def signature
      uri_signature.signature
    end

    # Returns true if +other+ matches the proper signature
    #
    # @return [Bool]
    def valid?(other)
      self.signature === other
    end

    private
    def uri?
      !@uri.blank?
    end

    def http_method?
      !@http_method.blank?
    end

    def secret?
      !@secret.blank?
    end

    def request_parser
      @request_parser ||= UriSigner::RequestParser.new(self.http_method, self.uri)
    end

    def request_signature
      @request_signature ||= UriSigner::RequestSignature.new(request_parser.http_method, request_parser.base_uri, request_parser.query_params)
    end

    def uri_signature
      @uri_signature ||= UriSigner::UriSignature.new(request_signature.signature, @secret)
    end
  end
end
