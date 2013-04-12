module UriSigner
  module Helpers
    module Hash
      def stringify_keys
        self.inject({}) do |options, (key, value)|
          options[key.to_s] = value
          options
        end
      end
    end
  end
end
