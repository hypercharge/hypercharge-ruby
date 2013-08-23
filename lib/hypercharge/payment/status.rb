module Hypercharge
  class Payment
    enum :Status do
      include ::Hypercharge::Concerns::Enum::UpcaseName
      include ::Hypercharge::Concerns::Enum::Inquirer
      NEW()
      USER()
      TIMEOUT()
      IN_PROGRESS()
      UNSUCCESSFUL()
      PENDING()
      PENDING_ASYNC()
      APPROVED()
      DECLINED()
      ERROR()
      CANCELED()
      REFUNDED()
      CHARGEBACKED()
      CHARGEBACK_REVERSED()
      PRE_ARBITRATED()
      CAPTURED()
      VOIDED()
    end
  end
end