# encoding: UTF-8

require "renum"


module Hypercharge
  # the config class, allows to set login, :password, :env
  # also allows to add faraday middleware, or configutaions like timeout
  class Config < Struct.new(:login, :password, :env, :defaults_seperator)

    DEFAULT_FARADAY_OPTIONS = {
      :headers => {'User-Agent' => "hypercharge-ruby #{Hypercharge::VERSION}"},
      :timeout => 30,
      :open_timeout => 5
    }.freeze

    # allows to configure faraday completely
    attr_accessor :faraday

    def initialize(*args)
      super

      # set
      uuid { OpenSSL::Digest::Digest.new('sha1').hexdigest("#{rand(100_000_000)}-#{Thread.current.object_id}-#{$$}-#{Time.now}") }

      self.defaults_seperator ||= '---'
      use_defaults!
    end

    # faraday configuration, allows to add middleware or to change options like timeoout, open_timeout
    #
    # @param [Hash] options  faraday contructor options, like :timeout, :open_timeout
    # @yield [faraday] faraday builder
    # @return [Faraday] faraday connection
    def faraday(options = {})
      @faraday ||= Faraday.new(DEFAULT_FARADAY_OPTIONS.merge(options)) do |builder|

        builder.request :basic_auth, login, password
        builder.request :json
        builder.request :xml_serialize

        builder.response :json,  :content_type => /\bjson$/
        builder.response :xml,  :content_type => /\bxml$/

        # builder.response :body_logger             # log requests to STDOUT
        yield builder if block_given?
        # add default Faraday.default_adapter if none present
        adapter_handler = builder.builder.handlers.find {|h| h.klass < Faraday::Adapter }
        builder.adapter  Faraday.default_adapter  if adapter_handler.nil?
      end
    end


    def defaults
      @defaults || {}
    end

    # reset all defaults
    def reset_defaults!
      @defaults = {}
    end

    def use_defaults!
      add_default('payment.transaction_id', 'payment_transaction.transaction_id') do |transaction_id|
         [transaction_id, uuid.call ].compact.join(defaults_seperator)
      end
    end

    def uuid &blk
      @uuid = blk if blk
      @uuid
    end

    # Allows to add key_path based defaults to request data,
    # the defaults are applied before the data gets validated via JSON-Schema.
    # This is used to add uniqueness to transaction_id which you would otherwise have to be unique pre request.
    #
    # @example
    #   Hypercharge.configure do |config|
    #     config.login    = login
    #     config.password = password
    #     config.env      = Hypercharge::Env::Sandbox
    #     # once in production use Live
    #     # config.env      = Hypercharge::Env::Live
    #
    #
    #     # (this will add transaction_id => value)
    #     config.add_default('payment.transaction_id', 'payment_transaction.transaction_id') do |transaction_id|
    #       UUID.generate(:compact)
    #     end
    #   end
    #
    def add_default(*key_paths, &blk)
      @defaults ||= {}
      key_paths.each do |key_path|
        @defaults[key_path.to_s] = blk
      end
    end


  end
end