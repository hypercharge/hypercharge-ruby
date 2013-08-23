module Hypercharge
  class Transaction
    enum :Status do
      include ::Hypercharge::Concerns::Enum::UpcaseName
      APPROVED()
      DECLINED()
      PENDING()
      PENDING_ASYNC()
      ERROR()
      VOIDED()
      CHARGEBACKED()
      REFUNDED()
      CHARGEBACK_REVERSED()
      PRE_ARBITRATED()
      REJECTED()
      CAPTURED()
    end
  end
end