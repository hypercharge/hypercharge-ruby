# encoding: UTF-8

require 'renum'
require 'hypercharge/transaction_notification'
require 'hypercharge/transaction/status'
require 'hypercharge/transaction/type'
require 'hypercharge/api_calls/transaction'

module Hypercharge
  class Transaction
    extend ApiCalls::Transaction

    attr_reader :transaction_type, :amount, :currency, :status,
                :unique_id, :transaction_id, :channel_token,
                :usage, :redirect_url, :customer_email, :customer_phone,
                :mode, :descriptor, :technical_message, :message,
                :wire_reference_id, :timestamp, :error, :billing_address,
                :recurring_scheduler


    def initialize(params)
      @transaction_type   = Type.with_name(params['transaction_type'])
      @timestamp          = Time.parse(params['timestamp']) if params.has_key?('timestamp')
      @mode               = Mode.with_name(params['mode'])
      @status             = Status.with_name(params['status'])
      @error              = Hypercharge::Errors.error_from_response_hash(params)

      @amount             = params['amount'].to_i if params.has_key?('amount')
      @currency           = params['currency']

      @unique_id          = params['unique_id']
      @transaction_id     = params['transaction_id']
      @channel_token      = params['channel_token']

      @descriptor         = params['descriptor']
      @usage              = params['usage']
      @technical_message  = params['technical_message']
      @message            = params['message']

      @customer_email     = params['customer_email']
      @customer_phone     = params['customer_phone']

      @redirect_url       = params['redirect_url']
      @wire_reference_id  = params['wire_reference_id']

      if params.has_key?('billing_address')
        @billing_address = Address.new(params['billing_address'])
      end


      if params['recurring_schedule']
        @recurring_scheduler = Hypercharge::Scheduler.new(params['recurring_schedule'])
      end

    end

    def refundable?
      status.approved? && transaction_type.refundable?
    end

    def voidable?
      status.approved? && transaction_type.voidable?
    end

    def self.notification(params)
      TransactionNotification.new(params).tap do |n|
        n.verify!(Hypercharge.config.password)
      end
    end

  end
end
