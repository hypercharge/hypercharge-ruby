# encoding: UTF-8

module Hypercharge
  module HTTPS
    module_function

    def validate_data_with_schema!(data, schema)

      errors = ::Hypercharge::Schema.validate(schema.hc_name, data)
      unless errors.size.zero?
        raise ::Hypercharge::Errors::InputDataError, errors.join("\n")
      end
    end

    def add_defaults!(params)
      Hypercharge::HashUtil.defaults!(params, ::Hypercharge.config.defaults)
    end

    # perform the actual HTTPS request
    # @param [String] http_method
    # @param [String] url
    # @param [Hash] params the requets params
    # @param [Class] schema to validate the request data with
    #
    def request(http_method, url, params, schema = nil, required_root_key = nil)

      if params.is_a?(Hash)
        params = add_defaults!(params)
      end

      if schema
        validate_data_with_schema!(params, schema)
      end

      # perform request
      response =  ::Hypercharge.config.faraday.send(http_method, url, params) do |req|

                      if url.to_s[-4..-1] == 'json'
                        req['Content-Type'] = 'application/json'
                        req['Accept']       = 'application/json'
                      else
                        req['Content-Type'] = 'text/xml'
                        req['Accept']       = 'text/xml'
                      end
                    end

      handle_response(response, required_root_key)
    rescue Faraday::Error::ClientError => e
      raise Errors.map_faraday_error(e), e
    end

    # handles response, raises some errors base on HTTP status
    def handle_response(response, required_root_key = nil)
      # at this point the FaradayMiddleware::ParseXml or JSON should have parsed
      # all valid responses into a Hash
      if response.env[:method] != :delete  && !response.body.is_a?(Hash)
        raise Errors::ResponseError, 'Unexpected or empty response'
      end

      case response.status
      when 401
        raise Errors::AuthenticationError, response['technical_message']
      when 500
        raise Errors::SystemError, response.body
      else
        if required_root_key
          response_data_for_key!(response.body, required_root_key)
        else
          response.body
        end
      end
    end

    def response_data_for_key!(reponse_hash, key)
      reponse_hash.fetch(key){
        raise Hypercharge::Errors::ResponseError, "Unexpected root key, expected: '#{key}' got '#{reponse_hash.keys.first}'"
      }
    end

  end
end