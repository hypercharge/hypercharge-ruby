require 'builder'

module Hypercharge
  class PaymentNotification

    attr_accessor :payment_transaction_channel_token, :payment_transaction_unique_id, :payment_transaction_transaction_type,
                  :payment_unique_id, :payment_transaction_id, :payment_status,
                  :notification_type,
                  :signature, :verified

    def initialize(params)
      @payment_transaction_channel_token     = params['payment_transaction_channel_token']
      @payment_transaction_unique_id         = params['payment_transaction_unique_id']
      @payment_transaction_transaction_type  = params['payment_transaction_transaction_type']
      @payment_unique_id                     = params['payment_unique_id']
      @payment_transaction_id                = params['payment_transaction_id']
      @payment_status                        = Payment::Status.with_name(params['payment_status'])
      @signature                             = params['signature']
      @notification_type                     = Payment::Type.with_name(params['notification_type'])
    end

    def verify!(password)
      generated_signature = OpenSSL::Digest::Digest.new('sha512').hexdigest("#{@payment_unique_id}#{password}")
      @verified = generated_signature == @signature
    end

    #
    alias_method :verified?, :verified

    # returns the xml echo as required by the hypercharge Wpf / Mobile API
    # your app needs to returned this xml string once the notification arrives via POST
    # if this echo is not returned the hypercharge wpf will repeat the notification with an incremental delay
    def echo
      xml = Builder::XmlMarkup.new(:indent => 2)
      xml.instruct!
      xml.notification_echo do
        xml.payment_unique_id @payment_unique_id
      end
      xml.target!
    end
    alias_method :ack, :echo

  end
end