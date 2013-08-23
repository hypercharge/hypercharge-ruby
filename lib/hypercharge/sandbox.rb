# encoding: UTF-8

require 'hypercharge/api_calls/sandbox'

module Hypercharge
  # This module provides API calls available on the Sansbox only.
  # It provides the ability to simulate chargebacks, chargeback reversals,
  # pre arbitrations, retrieval request on credit card related transactions
  # and also simulates chargebacked, rejected and charged debit sale transactions.
  # Additionaly you can create deposits on purchase on account and pay in advance transactions.
  # By using this interface, you can simulate a complete transaction lifecycle
  # and test your back systems to handle those events accordingly.
  module Sandbox
    extend ApiCalls::Sandbox

    # This module contains credit card numbers which yield a given result when used in the Sandbox
    module CreditCardNumbers
      VISA_APPROVED                         = 4200000000000000.freeze
      VISA_DECLINED                         = 4111111111111111.freeze
      MASTER_CARD_APPROVED                  = 5555555555554444.freeze
      MASTER_CARD_DECLINED                  = 5105105105105100.freeze

      # 3D-Secure enrolled
      THREE_D_SECURE_ENROLLED               = 4711100000000000.freeze

      # 3D-Secure enrolled failing authentication
      THREE_D_SECURE_FAILING_AUTHENTICATION = 4012001037461114.freeze

      # 3D-Secure unavailable - Card Not Participating
      THREE_D_SECURE_UNAVAILABLE            = 4200000000000000.freeze

      # Error in 3DSecure Network in first step of 3D-Secure authentication process
      THREE_D_SECURE_ERROR_IN_STEP_1        = 4012001037484447.freeze

      # Error in 3DSecure Network in second (asynchronous) step of 3D-Secure authentication process
      THREE_D_SECURE_ERROR_IN_STEP_2        = 4012001036273338.freeze
    end

    # This module contains bank account numbers which yield a given result when used in the Sandbox
    module BankAccountNumbers
      APPROVED = 1234567890.freeze
      DECLINED = 2345678901.freeze
      ERROR    = 3456789012.freeze
    end
  end
end