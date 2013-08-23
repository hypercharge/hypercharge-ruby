# encoding: UTF-8

module Hypercharge
  module ApiCalls
    # this module contians all API call which create, alter or find a Payment
    # within the Hypercharge gateway.
    #
    module Payment
      # Creates a WpfPayment
      # @param [Hash] data the data hash to initialze the WpfPayment with
      # @return [Payment] payment the payment with type WpfPayment
      # @example
      #   data = {
      #     :description          => "Purchase of concert tickets",               # Text displayed on hosted payment page
      #     :amount               => 50_00,                                       # amount in cents
      #     :currency             => 'EUR',                                       # currency code in ISO 4217
      #     :notification_url     => "https://YOUR-DOMAIN.com/wpf_notification",  # URL on your server to receive notifications
      #     :return_success_url   => "https://YOUR-DOMAIN.com/return_success",    # a URL on your server to receive notifications
      #     :return_failure_url   => "https://YOUR-DOMAIN.com/return_failure",    # URL on your server to receive notifications
      #     :return_cancel_url    => "https://YOUR-DOMAIN.com/return_cancel"      # URL on your server to receive notifications
      #   }
      #
      #   begin
      #     payment = Hypercharge::Payment.wpf(data)
      #
      #     if payment.should_redirect?
      #       # 1. save payment_unique_id to db
      #       save_payment_unique_id_with_order!(order, payment.payment_unique_id)
      #
      #       # 2. redirect user to hosted payment page
      #       redirect_to(payment.redirect_url)
      #     else
      #       # payment could not be initiated, check configurtaion
      #       # eg: transaction_types given which are not present in your configuration or country
      #     end
      #   rescue Faraday::Error::ClientError, Hypercharge::Errors::Error => e
      #     # network errors  =>  a subclass of Faraday::Error::ClientError
      #     # other errors    =>  a subclass Hypercharge::Errors::Error
      #   end
      def wpf(data)
        raise ArgumentError, "Expected Hash got '#{data.class}'" unless data.is_a?(Hash)
        request('payment', {:payment => data}, Hypercharge::Payment::Type::WpfPayment)
      end

      # Creates a MobilePayment
      # @param [Hash] data the data hash to initialze the MobilePayment with
      # @return [Payment] payment the payment with type MobilePayment
      # @example
      #   data = {
      #     :amount               => 50_00,                                       # amount in cents
      #     :currency             => 'EUR',                                       # currency code in ISO 4217
      #     :notification_url     => "https://YOUR-DOMAIN.com/wpf_notification",  # URL on your server to receive notifications
      #   }
      #
      #   begin
      #     payment = Hypercharge::Payment.mobile(data)
      #
      #     if payment.should_continue_in_mobile_app?
      #       # 1. save payment's unique_id to db
      #       save_payment_unique_id_and_submit_url_with_order!(order, payment.payment_unique_id, payment.submit_url)
      #
      #       # 2. use the submit_url on a mobile device to process the payment
      #     else
      #       # payment could not be initiated, check configurtaion
      #       # eg: transaction_types given which are not present in your configuration or country
      #     end
      #   rescue Faraday::Error::ClientError, Hypercharge::Errors::Error => e
      #     # error, either network errors =>  some subclass of Faraday::Error::ClientError
      #     # or a Hypercharge::Errors::ParsingError
      #   end
      def mobile(data)
        raise ArgumentError, "Expected Hash got '#{data.class}'" unless data.is_a?(Hash)
        request('payment', {:payment => data}, Hypercharge::Payment::Type::MobilePayment)
      end

      # Captures a previously APPROVED payment.
      # Note: This only works for payment's witch uses authorize as Transaction
      #
      # @param [String] unique_id unique_id as returned by `#wpf` and `#mobile`
      # @return [Transaction] capture the capture Transaction
      def capture(unique_id)
        request('payment/capture', :capture => {:unique_id => unique_id} )
      end

      # Cancel a Payment, this can only be done before a Transaction has been created
      #
      # @param [String] unique_id unique_id as returned by `#wpf` and `#mobile`
      # @return [Transaction] capture the capture Transaction
      def cancel(unique_id)
        request('payment/cancel', :cancel => {:unique_id => unique_id} )
      end

      # Voids a Payment, must be done on the same business day (acquirer timezone)
      #
      # @param [String] unique_id unique_id as returned by `#wpf` and `#mobile`
      def void(unique_id)
        request('payment/void', :void => {:unique_id => unique_id} )
      end

      # Refunds a Payment, must be done within timeframe defined by acquirer
      #
      # @param [String] unique_id unique_id as returned by `#wpf` and `#mobile`
      # @return [Transaction] refund the refund Transaction
      def refund(unique_id)
        request('payment/refund', {:refund => {:unique_id => unique_id}})
      end

      # Finds a payment by unique_id
      # @param [String] unique_id as returned by wpf and mobile
      # @return [Payment] payment
      def find(unique_id)
        request('payment/reconcile', {:reconcile => { :unique_id => unique_id}})
      end
      alias_method :reconcile, :find

      private

      def request(path, data, schema = nil)
        url = Hypercharge.config.env.payment_base_uri.join(path)

        data = Hypercharge::HashUtil.stringify_keys(data)

        if data['payment'] && schema
          data['payment']['type'] =  schema.hc_name
        end

        response_hash = Hypercharge::HTTPS.request(:post, url, data, schema, 'payment')

        Hypercharge::Payment.new( response_hash )
      end


    end
  end
end