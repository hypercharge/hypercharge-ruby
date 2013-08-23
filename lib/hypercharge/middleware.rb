# encoding: UTF-8

module Hypercharge
  module Middleware
    # This module holds Faraday Middleware
    autoload :BodyLogger,       'hypercharge/middleware/body_logger'
    autoload :XmlSerialize,     'hypercharge/middleware/xml_serialize'
  end
end