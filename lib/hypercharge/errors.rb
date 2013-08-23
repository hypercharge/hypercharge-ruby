# encoding: UTF-8

module Hypercharge
  # This module contains all of the internal errors.
  # These errors are _expected_ errors and as such don't typically represent
  # bugs in the Hypercharge SKD. These are meant as a way to detect errors and
  # display them in a user-friendly way.
  # eg all *declined* Transaction's will end up in an ProcessingError
  module Errors
    # Main superclass of any errors in Hypercharge. This provides some
    # convenience methods for setting the status code and add the `technical_message` `attr_accessor`.
    class Error < StandardError
      attr_accessor :technical_message

      def self.status_code(code)
       define_method(:status_code) { code }
      end

      def to_h
        {
          'code' => status_code,
          'message' => message,
          'technical_message' => technical_message
        }
      end
    end

    # Error with unspecified reason
    class SystemError < Error
      status_code 100
    end

    # Error class used to indicate maintenance mode.
    class MaintenanceError < Error
      status_code 101
    end

    # autentication failed for processing.
    class AuthenticationError < SystemError
      status_code 110
    end

    # configuration is inconsistent.
    class ConfigurationError < SystemError
      status_code 120
    end

    # Base class for Acquirer errors with the acquirer.
    class CommunicationError < Error
      status_code 200
    end

    # connection with the acquirer failed.
    class ConnectionError < CommunicationError
      status_code 210
    end

    # account with the acquirer is invalid.
    class AccountError < CommunicationError
      status_code 220
    end

    # requests to the acquirer times out.
    class TimeoutError < CommunicationError
      status_code 230
    end

    # response failed.
    class ResponseError < CommunicationError
      status_code 240
    end

    # response could not be parsed.
    class ParsingError < CommunicationError
      status_code 250
    end

    # Base class for all data input errors like invalid formats or characters.
    class InputDataError < Error
      status_code 300
    end

    # Transaction type is invalid.
    class InvalidTransactionTypeError < InputDataError
      status_code 310
    end

    # data is missing.
    class InputDataMissingError < InputDataError
      status_code 320
    end

    # entered data has invalid format.
    class InputDataFormatError < InputDataError
      status_code 330
    end

    # entered data has invalid characters.
    class InputDataInvalidError < InputDataError
      status_code 340
    end

    # request contains invalid XML.
    class InvalidXmlError < InputDataError
      status_code 350
    end

    class InvalidConentTypeError < InputDataError
      status_code 360
    end

    # Base class for all workflow errors like followup requests for not existend payment_transactions or transactions in wrong state for a follow up tranasction.
    class WorkflowError < Error
      status_code 400
    end

    # Transaction reference was not found for a follow up request.
    class ReferenceNotFoundError < WorkflowError
      status_code 410
    end

    # Transaction is in wrong state for follow up request.
    class ReferenceWorkflowError < WorkflowError
      status_code 420
    end

    # follow up request has allready been processed.
    class ReferenceInvalidatedError < WorkflowError
      status_code 430
    end

    # reference missmatches.
    class ReferenceMismatchError < WorkflowError
      status_code 440
    end

    # a request is resent to often within a specific timeout.
    class DoubletTransactionError < WorkflowError
      status_code 450
    end

    # the requested Transaction was not found.
    class TransactionNotFoundError < WorkflowError
      status_code 460
    end

    # Base class for all processing errors resulting from a request like invalid card number or expired / exceeded cards.
    class ProcessingError < Error
      status_code 500
    end

    # card number is not a valid credit card number.
    class InvalidCardError < ProcessingError
      status_code 510
    end

    # credit card has already been expired.
    class ExpiredCardError < ProcessingError
      status_code 520
    end

    # transaction is still pending.
    class TransactionPendingError < ProcessingError
      status_code 530
    end

    # requested amount exceeds card limit.
    class CreditExceededError < ProcessingError
      status_code 540
    end

    # Base class for all rocessing errors like declined transactions or risk management.
    class RiskError < ProcessingError
      status_code 600
    end

    # credit card number is blacklisted
    class CardBlacklistError < RiskError
      status_code 610
    end

    # bin (bank number within the cared card number) is blacklisted
    class BinBlacklistError < RiskError
      status_code 611
    end

    # country is blacklisted
    class CountryBlacklistError < RiskError
      status_code 612
    end

    # ip address is blacklisted
    class IpBlacklistError < RiskError
      status_code 613
    end

    # some value is blacklisted
    class BlacklistError < RiskError
      status_code 614
    end

    # transaction amount or count by credit card exceeds PanVelocityFilter.
    class CardLimitExceededError < RiskError
      status_code 620
    end

    # transaction amount or count exceeds ChannelVelocityFilter.
    class ChannelLimitExceededError < RiskError
      status_code 621
    end

    # transaction amount or count exceeds ContractVelocityFilter.
    class ContractLimitExceededError < RiskError
      status_code 622
    end

    # Velocity (amount / timeframe) exceeded on card
    class CardVelocityExceededError < RiskError
      status_code 623
    end

    # Amount Exceedes configured maximum
    class CardTicketSizeExceededError < RiskError
      status_code 624
    end

    # User limit exceeded
    class UserLimitExceededError < RiskError
      status_code 625
    end

    class MultipleFailureDetectionError < RiskError
      status_code 626
    end

    class CSDetectionError < RiskError
      status_code 627
    end

    class RecurringLimitExceededError < RiskError
      status_code 628
    end

    # Address Verfification System Error
    class AvsError < RiskError
      status_code 690
    end

    # Base class for all errors occured on Acquirer gateway like timeout or workflow errors.
    class AcquirerError < Error
      status_code 900
    end

    # Acquirer system is unavailable.
    class AcquirerSystemError < AcquirerError
      status_code 910
    end

    # configuration on Acquirer side is malformed or invalid.
    class AcquirerConfigurationError < AcquirerError
      status_code 920
    end

    # transaction data is malformed.
    class AcquirerDataError < AcquirerError
      status_code 930
    end

    # workflow errors accur on Acquirer side.
    class AcquirerWorkflowError < AcquirerError
      status_code 940
    end

    # Acquirer connection timed out.
    class AcquirerTimeoutError < AcquirerError
      status_code 950
    end

    # Acquirer connection fails.
    class AcquirerConnectionError < AcquirerError
      status_code 960
    end

    # maps status_codes to error Hypercharge::Errors
    ERROR_MAPPING = {
      100 => Hypercharge::Errors::SystemError,
      101 => Hypercharge::Errors::MaintenanceError,
      110 => Hypercharge::Errors::AuthenticationError,
      120 => Hypercharge::Errors::ConfigurationError,
      200 => Hypercharge::Errors::CommunicationError,
      210 => Hypercharge::Errors::ConnectionError,
      220 => Hypercharge::Errors::AccountError,
      230 => Hypercharge::Errors::TimeoutError,
      240 => Hypercharge::Errors::ResponseError,
      250 => Hypercharge::Errors::ParsingError,
      300 => Hypercharge::Errors::InputDataError,
      310 => Hypercharge::Errors::InvalidTransactionTypeError,
      320 => Hypercharge::Errors::InputDataMissingError,
      330 => Hypercharge::Errors::InputDataFormatError,
      340 => Hypercharge::Errors::InputDataInvalidError,
      350 => Hypercharge::Errors::InvalidXmlError,
      360 => Hypercharge::Errors::InvalidConentTypeError,
      400 => Hypercharge::Errors::WorkflowError,
      410 => Hypercharge::Errors::ReferenceNotFoundError,
      420 => Hypercharge::Errors::ReferenceWorkflowError,
      430 => Hypercharge::Errors::ReferenceInvalidatedError,
      440 => Hypercharge::Errors::ReferenceMismatchError,
      450 => Hypercharge::Errors::DoubletTransactionError,
      460 => Hypercharge::Errors::TransactionNotFoundError,
      500 => Hypercharge::Errors::ProcessingError,
      510 => Hypercharge::Errors::InvalidCardError,
      520 => Hypercharge::Errors::ExpiredCardError,
      530 => Hypercharge::Errors::TransactionPendingError,
      540 => Hypercharge::Errors::CreditExceededError,
      600 => Hypercharge::Errors::RiskError,
      610 => Hypercharge::Errors::CardBlacklistError,
      611 => Hypercharge::Errors::BinBlacklistError,
      612 => Hypercharge::Errors::CountryBlacklistError,
      613 => Hypercharge::Errors::IpBlacklistError,
      614 => Hypercharge::Errors::BlacklistError,
      620 => Hypercharge::Errors::CardLimitExceededError,
      621 => Hypercharge::Errors::ChannelLimitExceededError,
      622 => Hypercharge::Errors::ContractLimitExceededError,
      623 => Hypercharge::Errors::CardVelocityExceededError,
      624 => Hypercharge::Errors::CardTicketSizeExceededError,
      625 => Hypercharge::Errors::UserLimitExceededError,
      626 => Hypercharge::Errors::MultipleFailureDetectionError,
      627 => Hypercharge::Errors::CSDetectionError,
      628 => Hypercharge::Errors::RecurringLimitExceededError,
      690 => Hypercharge::Errors::AvsError,
      900 => Hypercharge::Errors::AcquirerError,
      910 => Hypercharge::Errors::AcquirerSystemError,
      920 => Hypercharge::Errors::AcquirerConfigurationError,
      930 => Hypercharge::Errors::AcquirerDataError,
      940 => Hypercharge::Errors::AcquirerWorkflowError,
      950 => Hypercharge::Errors::AcquirerTimeoutError,
      960 => Hypercharge::Errors::AcquirerConnectionError
    }.freeze


    FARDAY_ERROR_MAPPING = {
      # Faraday::Error::ClientError       =>
      # Faraday::Error::ConnectionFailed  =>
      # Faraday::Error::ResourceNotFound  =>
      'Faraday::Error::ParsingError'      => Hypercharge::Errors::ResponseError
      # Faraday::Error::TimeoutError      =>
      # Faraday::Error::MissingDependency =>
    }.freeze

    # maps Faraday error to Hypercharge::Errors
    # @param [Faraday::Error::ClientError] e error
    # @return [Faraday::Error::ClientError, Hypercharge::Errors::Error] error
    def self.map_faraday_error(e)
      FARDAY_ERROR_MAPPING[e.class.name] || e
    end

    # instaiates a Hypercharge::Errors::Error subclass from the response hash
    # @param [Hash] hash response hash
    # @return [Hypercharge::Errors::Error] error the instantiated error
    def self.error_from_response_hash(hash)
      code = hash['code'].to_i
      unless code.zero?
        error_class = ERROR_MAPPING[code] || Hypercharge::Errors::SystemError
        error_class.new(hash['message']).tap do |e|
          e.technical_message = hash['technical_message']
        end
      end
    end

  end
end