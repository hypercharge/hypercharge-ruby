# encoding: UTF-8

module Hypercharge
  module ApiCalls
    # this module contians all API calls to the Sandbox
    #
    module Sandbox

      # Create a ChargebackTransaction on a previously APPROVED Sale or Capture Transaction
      # @param [String] channel_token channel_token of the original transaction
      # @param [String] unique_id the unique_id of the the original transaction
      # @return [Transaction] chargeback
      def create_chargeback(channel_token, unique_id)
        request("bogus_event/chargeback/#{channel_token}/#{unique_id}")
      end

      # Create a PreArbitration on a Chargeback
      # @param [String] channel_token channel_token of the original chargeback
      # @param [String] unique_id the unique_id of the the original chargeback
      # @return [Transaction] pre_arbitration
      def create_pre_arbitration(channel_token, unique_id)
        request("bogus_event/pre_arbitration/#{channel_token}/#{unique_id}")
      end

      # Create a ChargebackReversal on a Chargeback
      # @param [String] channel_token channel_token of the original chargeback
      # @param [String] unique_id the unique_id of the the original chargeback
      # @return [Transaction] chargeback_reversal
      def create_chargeback_reversal(channel_token, unique_id)
        request("bogus_event/chargeback_reversal/#{channel_token}/#{unique_id}")
      end

      def create_retrieval_request(channel_token, unique_id)
        request("bogus_event/retrieval/#{channel_token}/#{unique_id}")
      end

      def create_deposit(channel_token, unique_id)
        request("bogus_event/deposit/#{channel_token}/#{unique_id}")
      end

      # Create a ChargebackTransaction on a previously APPROVED DebitSaleTransaction
      # @param [String] channel_token channel_token of the original transaction
      # @param [String] unique_id the unique_id of the the original transaction
      # @return [Transaction] chargeback
      def create_debit_chargeback(channel_token, unique_id)
        request("bogus_event/debit_chargeback/#{channel_token}/#{unique_id}")
      end

      # Reject a DebitSale
      # @param [String] channel_token channel_token of the original DebitSaleTransaction
      # @param [String] unique_id the unique_id of the the original DebitSaleTransaction
      # @return [Transaction] debit_sale with status REJECTED
      def reject_debit_sale(channel_token, unique_id)
        request("bogus_event/reject/#{channel_token}/#{unique_id}")
      end

      # Charge a DebitSale
      # @param [String] channel_token channel_token of the original DebitSaleTransaction
      # @param [String] unique_id the unique_id of the the original DebitSaleTransaction
      # @return [Transaction] debit_sale with status APPROVED
      def charge_debit_sale(channel_token, unique_id)
        request("bogus_event/charge/#{channel_token}/#{unique_id}")
      end

      def request(path)
        url = Hypercharge::Env::Sandbox.payment_transaction_base_uri.join(path)

        response_hash = Hypercharge::HTTPS.request(:post, url, nil, nil, 'payment_response')

        Hypercharge::Transaction.new( response_hash )
      end

    end
  end
end