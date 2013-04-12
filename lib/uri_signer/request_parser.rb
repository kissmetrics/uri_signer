module UriSigner
  # This object takes the raw request from the inbound API call. It takes the http method
  # used to make the request, and the full #raw_uri of the request. This object extracts the 
  # pieces necessary to pass it to the signing class. The key components are #http_method, #base_uri, 
  # and #query_params. #query_params has the core params extracted (any param starting with
  # an underscore)
  #
  # @example
  #   parser = UriSigner::RequestParser.new('get', 'https://api.example.com/core/people.json?_signature=1234&page=5&per_page=25')
  #
  #   parser.http_method
  #   # => "GET"
  #
  #   parser.https?
  #   # => true
  #
  #   parser.http?
  #   # => false
  #
  #   parser.raw_uri
  #   # => "https://api.example.com/core/people.json?_signature=1234&page=5&per_page=25
  #
  #   parser.query_params
  #   # => {"page"=>"5", "per_page"=>"25"}
  #
  #   parser.query_params?
  #   # => true
  #
  #   parser.signature
  #   # => '1234'
  #
  #   parser.signature?
  #   # => true
  #
  #   parser.base_uri
  #   # => "https://api.example.com/core/people.json"
  #
  class RequestParser
    # Create a new RequestParser instance
    #
    # @param http_method [String] The HTTP method used to make the request (GET, POST, PUT, or DELETE)
    # @param raw_uri [String] The raw URI from the request
    #
    # @return [void]
    def initialize(http_method, raw_uri)
      @http_method = http_method
      @raw_uri     = raw_uri

      raise UriSigner::Errors::MissingHttpMethodError.new("Please provide an HTTP method") unless http_method?
      raise UriSigner::Errors::MissingUriError.new("Please provide a URI") unless raw_uri?

      extract_core_params!
    end

    # Returns the uppercased HTTP Method
    #
    # @return [String]
    def http_method
      @http_method.upcase
    end

    # Returns true if the scheme/protocol used was HTTPS
    #
    # @return [Bool]
    def https?
      'https' == self.parsed_uri.scheme.downcase
    end

    # Returns true if the scheme/protocol used was HTTP
    #
    # @return [Bool]
    def http?
      !self.https?
    end

    # Returns the raw_uri that was provided in the constructor
    #
    # @return [String]
    def raw_uri
      @raw_uri
    end

    # Returns an instance of Addressable::URI that has been parsed.
    # This allows us to extract the core parts of the raw_uri
    #
    # @return [Addressable]
    def parsed_uri
      @parsed_uri ||= self.raw_uri.extend(UriSigner::Helpers::String).to_parsed_uri
    end

    # Returns the query params with the core params removed
    #
    # @return [Hash]
    def query_params
      @query_params ||= raw_query_params
    end

    # Returns true if query params were given
    #
    # @return [Bool]
    def query_params?
      !self.query_params.blank?
    end

    # Returns the base_uri of the request. This is the protocol, host with port, and the path.
    #
    # @return [String]
    def base_uri
      [self.parsed_uri.normalized_site, self.parsed_uri.normalized_path].join('')
    end

    # This returns the signature that was provided in the query params
    #
    # @return [String]
    def signature
      @_signature.extend(UriSigner::Helpers::String).escaped
    end

    # Returns true if a signature was provided in the raw_uri
    #
    # @return [Bool]
    def signature?
      !@_signature.blank?
    end

    private
    def http_method?
      !@http_method.blank?
    end

    def raw_uri?
      !@raw_uri.blank?
    end

    def raw_query_params
      @raw_query_params ||= Rack::Utils.parse_query(self.parsed_uri.query)
    end

    def extract_core_params!
      @_signature = raw_query_params.delete('_signature')
    end
  end
end
