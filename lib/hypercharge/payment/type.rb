# encoding: UTF-8

module Hypercharge
  class Payment
    enum :Type do
      include ::Hypercharge::Concerns::Enum::Inquirer
      WpfPayment()
      MobilePayment()

      alias_method :hc_name, :name
    end
  end
end