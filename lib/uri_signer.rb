root = File.expand_path(File.dirname(__FILE__))

# Utilities
require 'rack/utils'
require 'active_support/core_ext/object/blank.rb'

# Version
require File.join(root, 'uri_signer', 'version')

# Errors
require File.join(root, 'uri_signer', 'errors')

# Core Extension Helpers
require File.join(root, 'uri_signer', 'helpers')
require File.join(root, 'uri_signer', 'helpers', 'string')
require File.join(root, 'uri_signer', 'helpers', 'hash')

# Parsers and Signers
require File.join(root, 'uri_signer', 'query_hash_parser')
require File.join(root, 'uri_signer', 'request_parser')
require File.join(root, 'uri_signer', 'request_signature')
require File.join(root, 'uri_signer', 'uri_signature')
require File.join(root, 'uri_signer', 'signer')

module UriSigner
end
