# encoding: UTF-8

module Hypercharge
  module Concerns # :nodoc:
    module Enum # :nodoc:
      # This module contains mixins for renums
      #
      module UpcaseName

        def self.included(base)
          base.extend ClassMethods
        end

        module ClassMethods
          def with_name(name)
            super(name.to_s.upcase) || super(name)
          end
        end

        def hc_name
          name.downcase
        end
      end

      module CamelizedName
        def self.included(base)
          base.extend ClassMethods
        end

        module ClassMethods
          def with_name(name)
            super(::Hypercharge::StringHelpers.camelize(name)) || super(name)
          end
        end

        def hc_name
          ::Hypercharge::StringHelpers.underscore(name)
        end
      end

      # provides ActiveSupport::StringInquirer like behaviour for REnum's
      #
      #  enum :Status, [:APPROVED, :DECLINED]
      #  o = Status::APPROVED
      #  o.approved? => true
      module Inquirer

        def method_missing(m, *a)
          if m[-1] == "?" && m.size > 1
            self.class.class_eval do
              define_method m do
                ::Hypercharge::StringHelpers.underscore(m[0...-1]) == \
                  ::Hypercharge::StringHelpers.underscore(self.name)
              end
            end
            send(m)
          else
            super
          end
        end

      end

    end

  end
end