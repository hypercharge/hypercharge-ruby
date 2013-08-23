# encoding: UTF-8

require 'hypercharge/paginated_collection'

module Hypercharge
  module ApiCalls
    # this module contians all API call which create or alter Transaction's
    # within the Hypercharge gateway.
    module Transaction

      # Authorize a Credit Card
      # @api public
      # @param [String] channel_token
      # @param [Hash] data request hash
      # @return [Transaction] payment_transaction
      #
      # @example
      #   data = {
      #     :transaction_type => "authorize",
      #     :transaction_id   => "40208",
      #     :usage            => "40208 concert tickets",
      #     :remote_ip        => "245.253.2.12",
      #     :amount           => 5000,
      #     :currency         => "USD",
      #     :card_holder      => "Max Mustermann",
      #     :card_number      => "4200000000000000",
      #     :cvv              => "123",
      #     :expiration_month => "12",
      #     :expiration_year  => "2013",
      #     :customer_email   => "max.mustermann@example.com",
      #     :customer_phone   => "+49301234567",
      #     :billing_address" => {
      #       :first_name => "Max",
      #       :last_name  => "Mustermann",
      #       :address1   => "Muster Str. 12",
      #       :zip_code   => "10178",
      #       :city       => "Berlin",
      #       :country    => "DE"
      #     }
      #   }
      #   payment_transaction = Hyperchrage::Transaction.authroize('011e8d5cc1a56058cc50440c264f5063', data)
      #
      def authorize(channel_token, data)
        request(channel_token, data, Hypercharge::Transaction::Type::Authorize)
      end

      # Authorize a Credit Card using 3D-Secure
      # @api public
      # @param [String] channel_token
      # @param [Hash] data request hash
      # @return [Transaction] payment_transaction
      def authorize3d(channel_token, data)
        request(channel_token, data, Hypercharge::Transaction::Type::Authorize3d)
      end

      def sale(channel_token, data)
        request(channel_token, data, Hypercharge::Transaction::Type::Sale)
      end

      def sale3d(channel_token, data)
        request(channel_token, data, Hypercharge::Transaction::Type::Sale3d)
      end

      def capture(channel_token, data)
        request(channel_token, data, Hypercharge::Transaction::Type::Capture)
      end

      def refund(channel_token, data)
        request(channel_token, data, Hypercharge::Transaction::Type::Refund)
      end

      def void(channel_token, data)
        request(channel_token, data, Hypercharge::Transaction::Type::Void)
      end

      def init_recurring_sale(channel_token, data)
        request(channel_token, data, Hypercharge::Transaction::Type::InitRecurringSale)
      end

      def init_recurring_authorize(channel_token, data)
        request(channel_token, data, Hypercharge::Transaction::Type::InitRecurringAuthorize)
      end

      def recurring_sale(channel_token, data)
        request(channel_token, data, Hypercharge::Transaction::Type::RecurringSale)
      end

      def ideal_sale(channel_token, data)
        request(channel_token, data, Hypercharge::Transaction::Type::IdealSale)
      end

      def referenced_fund_transfer(channel_token, data)
        request(channel_token, data, Hypercharge::Transaction::Type::ReferencedFundTransfer)
      end

      def debit_sale(channel_token, data)
        request(channel_token, data, Hypercharge::Transaction::Type::DebitSale)
      end

      def purchase_on_account(channel_token, data)
        request(channel_token, data, Hypercharge::Transaction::Type::PurchaseOnAccount)
      end

      def pay_in_advance(channel_token, data)
        request(channel_token, data, Hypercharge::Transaction::Type::PayInAdvance)
      end

      def payment_on_delivery(channel_token, data)
        request(channel_token, data, Hypercharge::Transaction::Type::PaymentOnDelivery)
      end

      def pay_pal(channel_token, data)
        request(channel_token, data, Hypercharge::Transaction::Type::PayPal)
      end

      def init_recurring_debit_sale(channel_token, data)
        request(channel_token, data, Hypercharge::Transaction::Type::InitRecurringDebitSale)
      end

      def init_recurring_debit_authorize(channel_token, data)
        request(channel_token, data, Hypercharge::Transaction::Type::InitRecurringDebitAuthorize)
      end

      def recurring_debit_sale(channel_token, data)
        request(channel_token, data, Hypercharge::Transaction::Type::RecurringDebitSale)
      end

      #
      def find(channel_token, unique_id)
        url = Hypercharge.config.env.payment_transaction_base_uri.join("reconcile/#{channel_token}")

        response_hash = Hypercharge::HTTPS.request(:post, url, { :reconcile => {:unique_id => unique_id}}, nil, 'payment_response')

        Hypercharge::Transaction.new( response_hash )
      end
      alias_method :reconcile, :find


      def page(channel_token, data = {})
        #
        data[:page] ||= 1
        data[:start_date] ||= Date.new(1970,1,1)

        url = Hypercharge.config.env.payment_transaction_base_uri.join("reconcile/by_date/#{channel_token}")

        # perform the reconcile request
        response_hash = Hypercharge::HTTPS.request(:post, url, {:reconcile => data}, nil, 'payment_responses')

        # make payment_response an array
        response_hash['payment_response'] = [response_hash['payment_response']] unless response_hash['payment_response'].is_a?(Array)

        #
        PaginatedCollection.create(response_hash['page'], response_hash['per_page'], response_hash['total_count']) do |c|
          c.concat response_hash['payment_response'].map{ |response_hash| Hypercharge::Transaction.new( response_hash ) }
        end
      end
      alias_method :reconcile_by_date, :page

      def each(channel_token, data = {})
        begin
          collection = page(channel_token, data)
          collection.each do |item|
            yield item
          end
          data[:page] = collection.next_page
        end while collection.next_page?
      end

      private

      def request(channel_token, data, schema)
        raise ArgumentError, "Expected Hash got '#{data.class}'" unless data.is_a?(Hash)

        # root
        data = Hypercharge::HashUtil.stringify_keys({:payment_transaction => data})
        # add payment_transaction
        data['payment_transaction']['transaction_type'] = schema.hc_name

        url = Hypercharge.config.env.payment_transaction_base_uri.join("process/#{channel_token}")

        response_hash = Hypercharge::HTTPS.request(:post, url, data, schema, 'payment_response')

        Hypercharge::Transaction.new( response_hash )
      end


    end
  end
end
