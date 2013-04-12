module UriSigner
  module Errors
    autoload :MissingQueryHashError,            File.join(File.dirname(__FILE__), 'errors/missing_query_hash_error')
    autoload :MissingHttpMethodError,           File.join(File.dirname(__FILE__), 'errors/missing_http_method_error')
    autoload :MissingBaseUriError,              File.join(File.dirname(__FILE__), 'errors/missing_base_uri_error')
    autoload :MissingSignatureStringError,      File.join(File.dirname(__FILE__), 'errors/missing_signature_string_error')
    autoload :MissingSecretError,               File.join(File.dirname(__FILE__), 'errors/missing_secret_error')
    autoload :MissingUriError,                  File.join(File.dirname(__FILE__), 'errors/missing_uri_error')
  end
end
