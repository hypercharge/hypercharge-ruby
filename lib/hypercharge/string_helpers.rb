
module Hypercharge
  module StringHelpers
    extend self

    def camelize(str)
      str.to_s.gsub(/^(.)/){|m| m.upcase } \
        .gsub(/_(.)/){|m| m.upcase } \
        .gsub('_', '')
    end

    def underscore(str)
      str.to_s.gsub(/([A-Z][a-z])/){|m| "_#{m.downcase}" } \
        .gsub(/^_|_$/, '').downcase
    end
  end
end