module Hypercharge
  class Transaction
    enum :Type do
      include ::Hypercharge::Concerns::Enum::CamelizedName
      Sale(:refundable => true, :voidable => true)
      Sale3d(:refundable => true, :voidable => true)
      Authorize(:voidable => true)
      Authorize3d(:voidable => true)
      Capture(:refundable => true, :voidable => true)
      Refund(:voidable => true)
      Void()
      Chargeback()
      ChargebackReversal()
      PreArbitration()
      InitRecurringSale()
      RecurringSale(:refundable => true, :voidable => true)
      IdealSale()
      ReferencedFundTransfer()
      DebitSale()
      SepaDebit()
      DirectPay24Sale()
      GiroPaySale()
      PaySafeCardSale()
      InitRecurringAuthorize()
      DebitChargeback()
      PurchaseOnAccount()
      PayInAdvance()
      Deposit()
      PaymentOnDelivery()
      PayPal()
      InitRecurringDebitSale()
      InitRecurringDebitAuthorize()
      RecurringDebitSale()
      BarzahlenSale()

      attr_reader :refundable, :voidable
      alias_method :refundable?, :refundable
      alias_method :voidable?, :voidable

      def init(opt = {})
        @refundable = !!opt[:refundable]
        @voidable = !!opt[:voidable]
      end
    end
  end
end