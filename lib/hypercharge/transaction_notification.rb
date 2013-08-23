# encoding: UTF-8

require 'digest/sha1'


module Hypercharge
  class TransactionNotification

    attr_reader :signature, :channel_token, :unique_id, :transaction_type, :status, :transaction_id, :verified

    def initialize(params)
      @signature        = params['signature']
      @channel_token    = params['channel_token']
      @unique_id        = params['unique_id']
      @transaction_type = Hypercharge::Transaction::Type.with_name(params['transaction_type'])
      @status           = Hypercharge::Transaction::Status.with_name(params['status'])
      @transaction_id   = params['transaction_id']
    end

    def verify!(password)
      generated_signature = Digest::SHA1.hexdigest("#{@unique_id}#{password}")
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
        xml.unique_id @unique_id
      end
      xml.target!
    end
    alias_method :ack, :echo

  end
end
