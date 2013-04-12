module UriSigner
  # This is responsible for preparing the raw request in the format necessary for signing. API URI signatures come in a few different flavors. This one
  # will take HTTP_METHOD & ESCAPED_BASE_URI & SORTED_AND_ESCAPED_QUERY_PARAMS
  #
  # @example
  #
  #   request_signature = UriSigner::RequestSignature.new('get', 'https://api.example.com/core/people.json', { 'page' => 5, 'per_page' => 25 })
  #
  #   request_signature.http_method
  #   # => 'GET'
  #
  #   request_signature.base_uri
  #   # => 'https://api.example.com/core/people.json'
  #
  #   request_signature.query_params
  #   # => { 'page' => 5, 'per_page' => 25' }
  #
  #   request_signature.query_params?
  #   # => true
  #
  #   request_signature.encoded_base_uri
  #   # => "https%3A%2F%2Fapi.example.com%2Fcore%2Fpeople.json"
  #
  #   request_signature.encoded_query_params
  #   # => "page%3D5%26per_page%3D25"
  #
  #   request_signature.signature
  #   # => "GET&https%3A%2F%2Fapi.example.com%2Fcore%2Fpeople.json&page%3D5%26per_page%3D25"
  #
  class RequestSignature

    # The default separator used to join the http_method, encoded_base_uri, and encoded_query_params
    attr_reader :separator

    # Create a new RequestSignature instance
    #
    # @param http_method [String] The HTTP method from the request (GET, POST, PUT, or DELETE)
    # @param base_uri [String] The base URI of the request. This is everything except the query string params
    # @param query_params [Hash] A hash of the provided query string params
    #
    # It's required that you provide at least the http_method and base_uri. Params are optional
    #
    # @return [void]
    def initialize(http_method, base_uri, query_params = {})
      @http_method  = http_method
      @base_uri     = base_uri
      @query_params = query_params
      @separator    = '&'

      raise UriSigner::Errors::MissingHttpMethodError.new("Please provide an HTTP method") unless http_method?
      raise UriSigner::Errors::MissingBaseUriError.new("Please provide a Base URI") unless base_uri?
    end

    # Returns the full signature string
    #
    # @return [String]
    def signature
      core_signature = [self.http_method, self.encoded_base_uri]
      core_signature << self.encoded_query_params if self.query_params?
      core_signature.join(self.separator)
    end
    alias :to_s :signature

    # Returns the uppercased HTTP Method
    #
    # @return [String]
    def http_method
      @http_method.upcase
    end

    # Returns the base URI
    #
    # @return [String]
    def base_uri
      @base_uri
    end

    # Returns the encoded base_uri
    #
    # This can be used for comparison to ensure the escaping is what you want
    #
    # @return [String] Escaped string of the base_uri
    def encoded_base_uri
      self.base_uri.extend(UriSigner::Helpers::String).escaped
    end

    # Returns the Query String parameters
    #
    # @return [Hash] The keys are stringified
    def query_params
      @query_params.extend(UriSigner::Helpers::Hash).stringify_keys
    end

    # Returns true if query params were provided
    #
    # @return [Bool]
    def query_params?
      !@query_params.blank?
    end

    # Returns the encoded query params as a string
    #
    # This joins the keys and values in one string, then joins them. Then it will escape the final contents.
    #
    # @return [String] Escaped string of the query params
    def encoded_query_params
      query_params_string.extend(UriSigner::Helpers::String).escaped
    end

    private
    def http_method?
      !@http_method.blank?
    end

    def base_uri?
      !@base_uri.blank?
    end

    def query_params_string
      @query_params_string ||= UriSigner::QueryHashParser.new(self.query_params).to_s
    end
  end
end
