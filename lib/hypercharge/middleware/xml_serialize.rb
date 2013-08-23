# encoding: UTF-8

require 'faraday'
require 'builder'


module Hypercharge
  module Middleware
    # serializes request hash to XML
    #
    class XmlSerialize < Faraday::Middleware
      def call(env, options = {})
        @options = options
        if serialize?(env)
          env[:body] = build_xml(env[:body])
        end
        @app.call(env)
      end

      def serialize?(env)
        if env[:request_headers]['Content-Type'] == 'text/xml'
          env[:body].is_a?(Hash) && env[:body].keys.any?
        else
          false
        end
      end

      def build_xml(data)
        xml = Builder::XmlMarkup.new(:indent => 2)
        xml.instruct!
        xml_add(xml, data)
        xml.target!.strip
      end

      def xml_add(xml, data)
        keys_sorted = data.keys.sort{|a,b| a.to_s <=> b.to_s}
        keys_sorted.each do |k|
          v = data[k]
          if v.is_a?(Hash)
            xml.tag!(k) do
              xml_add(xml, v)
            end
          elsif v.is_a?(Array)
            # super simple singularize
            singular_key = "#{k}".gsub(/s$/, '')
            xml.tag!(k) do
              v.each{|e| xml.tag!(singular_key, e) }
            end

            # v.each{|e| xml.tag!(k, e) }
          else
            xml.tag!(k, v)
          end
        end
      end
    end
  end

end