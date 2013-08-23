# encoding: UTF-8

module Hypercharge
  # This module is used to transform a request hash, it stringifies the keys
  # so it can be validated with json-schema, and applies defaults
  module HashUtil
    module_function

    # stringifies keys and add defaults
    # @param [Hash] hash
    # @param [Hash] defaults
    # @return [Hash] hash
    def defaults!(hash, defaults)
      hash = stringify_keys(hash)
      apply_defaults(hash, defaults)
    end

    # Transforms and return hash base on defaults hash.
    # The keys in defaults Hash can either be a a key or a
    # key_path (like payment.transaction_id). The values of Hash  can be a proc
    # or a fixed value
    def apply_defaults(hash, defaults)
      defaults.each do |key_path, transformation|
        path = key_path.to_s.split('.')
        key = path.pop
        parent = path.size > 0 ? fetch_path(hash, path) : fetch_parent_of_key(hash, key)
        if parent.is_a?(Hash)
          parent[key] = transformation.respond_to?(:call) ? transformation.call(parent[key]) : transformation
        end
      end
      hash
    end

    # fetches a valus from a hash based on a key_path
    #
    #   hash = {:a => {:b => {:c => 'the c value'}}}
    #   fetch_path(hash, %w(a b c) => 'the c value'
    #
    def fetch_path(hash, path)
      path.reduce(hash) do |node, name|
        node ? node[name] : nil
      end
    end

    # recursive finds the parent hash key
    #
    #   hash = {:a => {:b => {:c => 'the c value'}}}
    #   fetch_parent_of_key(hash, :c) => {:c => 'the c value'}
    #
    def fetch_parent_of_key(hash, key)
      hash.key?(key) ? hash : hash.values.inject(nil) {|memo, v| memo ||= fetch_parent_of_key(v, key) if v.is_a?(Hash)}
    end

    # like active support, but recursive
    def stringify_keys(hash)
      Hash[ hash.map{|k, v| [k.to_s, v.is_a?(Hash) ? stringify_keys(v) : v] }]
    end

  end
end