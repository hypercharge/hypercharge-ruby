# encoding: UTF-8

require 'faraday'

module Hypercharge
  module Middleware
    # logs the request and response body
    # and masks all sesitive data
    class BodyLogger < Faraday::Response::Logger

      def call(env)
        debug('request') { loggable_string(env[:body]) }
        super
      end

      def on_complete(env)
        super
        debug('response') { loggable_string(env[:body]) }
      end


      def loggable_string(xml_string)
        xml_string.to_s.gsub(/<card_number>([^<]+)<\/card_number>/,
            "<card_number>xxxx-xxxx-xxxx-xxx</card_number>").
          gsub(/\d{13,}/, "xxxx-xxxx-xxxx-xxx").
          gsub(/<cvv>([^<]+)<\/cvv>/, "<cvv>xxx</cvv>").
          gsub(/<expiration_month>([^<]+)<\/expiration_month>/,
            "<expiration_month>xx</expiration_month>").
          gsub(/<expiration_year>([^<]+)<\/expiration_year>/,
            "<expiration_year>xxxx</expiration_year>").
          gsub(/<bank_account_number>([^<]+)<\/bank_account_number>/,
            "<bank_account_number>xxxxxxxxxx</bank_account_number>")
      end
    end
  end
end