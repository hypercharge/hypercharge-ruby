# encoding: UTF-8

require "renum"
require "addressable/uri"

module Hypercharge
  # This represent Hypercharge's environments.
  # The Sandbox is meant for testing and development, and will never perform any real payments.
  # The Live environment can perform Live and Test Payments and Transactions, represendted as Hypercharge::Mode
  #
  enum :Env do
    Sandbox(:payment_base_uri              => 'https://testpayment.hypercharge.net'.freeze,
            :payment_transaction_base_uri  => 'https://test.hypercharge.net'.freeze)

    # Sandbox(:payment_base_uri              => 'http://payment.hypercharge.dev'.freeze,
    #         :payment_transaction_base_uri  => 'http://gateway.hypercharge.dev'.freeze)

    Live(:payment_base_uri              => 'https://payment.hypercharge.net'.freeze,
         :payment_transaction_base_uri  => 'https://hypercharge.net'.freeze)


    attr_accessor :payment_base_uri, :payment_transaction_base_uri

    def init(config)
      @payment_base_uri             = Addressable::URI.parse(config[:payment_base_uri])
      @payment_transaction_base_uri = Addressable::URI.parse(config[:payment_transaction_base_uri])
    end
  end

end