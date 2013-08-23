# encoding: UTF-8

require 'renum'
require 'hypercharge/payment_notification'
require 'hypercharge/payment/status'
require 'hypercharge/payment/type'
require 'hypercharge/api_calls/payment'

module Hypercharge
  # A Payment is a container which can include more then one Transactions
  # e.g. a WpfPayment, which initially was payed with credit card (SaleTransaction)
  # and later gets refunded (RefundTransaction).
  # Payments have a two step workflow.
  # There are two types of Payments: WpfPayment and MobilePayment
  class Payment
    extend ApiCalls::Payment

    attr_reader :type, :status, :unique_id, :transaction_id, :mode, :timestamp,
                :amount, :currency, :redirect_url, :cancel_url, :timestamp, :usage,
                :message, :technical_message, :customer_email, :customer_phone,
                :customer_email, :customer_phone, :payment_transactions,
                :error, :payment_methods, :recurring_scheduler

    # instantiates a Payment with response hash
    # @param [Hash] params the response hash
    def initialize(params)
      @type               = Payment::Type.with_name(params['type'])
      @status             = Payment::Status.with_name(params['status'])
      @mode               = Hypercharge::Mode.with_name(params['mode'])

      @unique_id          = params['unique_id']
      @transaction_id     = params['transaction_id']
      @timestamp          = Time.parse(params['timestamp']) if params.has_key?('timestamp')
      @amount             = params['amount'].to_i  if params.has_key?('amount')
      @currency           = params['currency']
      @message            = params['message']
      @technical_message  = params['technical_message']
      @redirect_url       = params['redirect_url']
      @cancel_url         = params['cancel_url']
      @error              = Hypercharge::Errors.error_from_response_hash(params)

      @customer_email     = params['customer_email']
      @customer_phone     = params['customer_phone']

      @payment_methods    = params['payment_methods']
      if @payment_methods.is_a?(Hash)
        pm = @payment_methods.values.first
        @payment_methods    = if pm.is_a?(Array) then pm else [pm] end
      end

      if params['recurring_schedule']
        @recurring_scheduler = Hypercharge::Scheduler.new(params['recurring_schedule'])
      end

      @payment_transactions = []
      if params.has_key?('payment_transaction')
        # ensure array
        payment_transactions = params['payment_transaction']
        payment_transactions = [payment_transactions] unless payment_transactions.is_a?(Array)

        payment_transactions.each do |trx|
          @payment_transactions << Transaction.new(trx)
        end
      end
    end

    #
    def wpf?
      type && type.wpf_payment?
    end

    def mobile?
      type && type.mobile_payment?
    end

    def should_redirect?
      wpf? &&  status.new? && !redirect_url.nil?
    end

    def should_continue_in_mobile_app?
      mobile? &&  status.new? && !redirect_url.nil?
    end

    # the url where MobilePayment's needs to be submitted to in step 2
    # @return [String] submit_url
    def submit_url
      redirect_url if mobile?
    end

    # Creates a PaymentNotification from POST params
    # @param [Hash] params  the POST params
    # @return [PaymentNotification] notification
    def self.notification(params)
      PaymentNotification.new(params).tap do |n|
        n.verify!(Hypercharge.config.password)
      end
    end
  end
end