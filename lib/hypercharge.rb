# encoding: UTF-8

require 'faraday'
require 'faraday_middleware'
require 'json-schema'
require 'hypercharge/schema'
require 'hypercharge/version'
require 'hypercharge/extensions'
require 'hypercharge/errors'
require 'hypercharge/string_helpers'


module Hypercharge

  autoload :HTTPS,                  'hypercharge/https'
  autoload :HashUtil,               'hypercharge/hash_util'
  autoload :Concerns,               'hypercharge/concerns'
  autoload :Config,                 'hypercharge/config'
  autoload :Env,                    'hypercharge/env'
  autoload :Mode,                   'hypercharge/mode'
  autoload :Errors,                 'hypercharge/errors'
  autoload :Middleware,             'hypercharge/middleware'
  autoload :Address,                'hypercharge/address'
  autoload :Payment,                'hypercharge/payment'
  autoload :Transaction,            'hypercharge/transaction'
  autoload :Scheduler,              'hypercharge/scheduler'
  autoload :SchedulerNotification,  'hypercharge/scheduler_notification'
  autoload :Sandbox,                'hypercharge/sandbox'

  # Get or set the config. When an argument is specified,
  # the config will be set. If no argument is specified, the current config
  # will be returned.
  #
  # @param [Config] config  Hypercharge config
  #
  # @return [Config] config
  def self.config(config = nil )
    @config = config if config
    @config
  end


  # configure the Hypercharge client with credentials, optionally add faraday middleware or set timeouts, open_timeout
  # or other faraday constructor parameters
  # @example
  #   Hypercharge.configure do |config|
  #     config.login    = login
  #     config.password = password
  #     config.env      = Hypercharge::Env::Sandbox
  #     # once in production use Live
  #     # config.env      = Hypercharge::Env::Live
  #
  #     # configure faraday middlewre
  #     config.faraday(:timeout => 30, :open_timeout => 5) do |faraday|
  #       faraday.request :some_request_middleware
  #       faraday.use :instrumentation
  #     end
  #   end
  #
  def self.configure
    if self.config.nil?
      Faraday::Request.register_middleware  :xml_serialize      => lambda{ Hypercharge::Middleware::XmlSerialize }
      Faraday::Response.register_middleware :xml                => lambda{ FaradayMiddleware::ParseXml }
      Faraday::Response.register_middleware :body_logger        => lambda{ Hypercharge::Middleware::BodyLogger }
    end

    self.config Config.new

    yield self.config
  end


end
