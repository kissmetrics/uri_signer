module UriSigner
  # This object takes in a hash, most likely from Rack::Utils.parse_query, and transforms it into
  # a query string that's used for signing requests. It takes a hash, transforms the hash into a
  # query string that has it's parts ordered accordingly.
  #
  # @example
  #   parser = UriSigner::QueryHashParser.new({"order"=>["name:desc", "id:desc"], "where"=>["name:nate", "id:123"]})
  #
  #   parser.to_s
  #   # => "order=name:desc&order=id:desc&where=name:nate&where=id:123"
  #
  class QueryHashParser
    # Creates a new QueryHashParser instance
    #
    # @param query_hash [Hash] A hash of key/values to turn into a query stringo
    #
    # @return [void]
    def initialize(query_hash)
      @query_hash = query_hash

      raise UriSigner::Errors::MissingQueryHashError.new('Please provide a query string hash') unless query_hash?
    end

    # Returns the hash (key/values) as an ordered query string. This joins the keys and values, and then
    # joins it all with the ampersand. This is not escaped
    #
    # @return [String]
    def to_s
      parts = @query_hash.sort.inject([]) do |arr, (key,value)|
        if value.kind_of?(Array)
          value.each do |nested|
            arr << "%s=%s" % [key, nested]
          end
        else
          arr << "%s=%s" % [key, value]
        end
        arr
      end
      parts.join('&')
    end

    private
    def query_hash?
      @query_hash.kind_of?(Hash) && !@query_hash.blank?
    end
  end
end
