module Rack
  module Utils
    DEFAULT_SEP = /[&;] */n

    def self.key_space_limit=(value)
      @@key_space_limit = value
    end

    def self.key_space_limit
      @@key_space_limit
    end

    self.key_space_limit = 65536

    def self.escape(s)
      s.to_s.gsub(/([^ a-zA-Z0-9_.-]+)/n) {
        '%'+$1.unpack('H2'*bytesize($1)).join('%').upcase
      }.tr(' ', '+')
    end

    # Unescapes a URI escaped string. (Stolen from Camping).
    def self.unescape(s)
      s.tr('+', ' ').gsub(/((?:%[0-9a-fA-F]{2})+)/n){
        [$1.delete('%')].pack('H*')
      }
    end

    def self.parse_query(qs, d = nil)
      params = {}

      max_key_space = key_space_limit
      bytes = 0

      (qs || '').split(d ? /[#{d}] */n : DEFAULT_SEP).each do |p|
        k, v = p.split('=', 2).map { |x| unescape(x) }

        if k
          bytes += k.size
          if bytes > max_key_space
            raise RangeError, "exceeded available parameter key space"
          end
        end

        if cur = params[k]
          if cur.class == Array
            params[k] << v
          else
            params[k] = [cur, v]
          end
        else
          params[k] = v
        end
      end

      return params
    end

    if ''.respond_to?(:bytesize)
      def self.bytesize(string)
        string.bytesize
      end
    else
      def self.bytesize(string)
        string.size
      end
    end
  end
end
