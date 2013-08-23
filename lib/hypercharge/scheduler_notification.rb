# encoding: UTF-8

module Hypercharge
  #
  class SchedulerNotification
    enum :Type do
      include ::Hypercharge::Concerns::Enum::Inquirer
      RECURRING_EVENT()
      SCHEDULER_WILL_EXPIRE()
    end

    attr_reader :unique_id, :due_date, :end_date,
                :payment_transaction_unique_id, :payment_transaction_channel_token, :payment_transaction_status,
                :signature, :notification_type, :verified

    alias_method :verified?, :verified
    alias_method :type, :notification_type


    def initialize(params)
      if params['notification_type'] == 'RecurringEvent'
        @notification_type          = Type::RECURRING_EVENT
        @payment_transaction_status = Hypercharge::Transaction::Status.with_name(params['payment_transaction_status'])
        @due_date                   = Date.parse(params['recurring_event_due_date']) if params['recurring_event_due_date']
      elsif params['notification_type'] == 'RecurringSchedule' \
        && params['recurring_schedule_status'] == 'expiring'
        @notification_type    = Type::SCHEDULER_WILL_EXPIRE
        @end_date             = Date.parse(params['recurring_schedule_end_date']) if params['recurring_schedule_end_date']
      end

      @unique_id                          = params['recurring_schedule_unique_id']
      @payment_transaction_unique_id      = params['payment_transaction_unique_id']
      @payment_transaction_channel_token  = params['payment_transaction_channel_token']
      @signature                          = params['signature']
    end



    def verify!(password)
      generated_signature = OpenSSL::Digest::Digest.new('sha512').hexdigest("#{@unique_id}#{password}")
      @verified = generated_signature == @signature
    end

    # returns the xml echo as required by the hypercharge
    # your app needs to returned this xml string once the notification arrives via POST
    # if this echo is not returned the hypercharge wpf will repeat the notification with an incremental delay
    def echo
      xml = Builder::XmlMarkup.new(:indent => 2)
      xml.instruct!
      xml.notification_echo do
        xml.unique_id @unique_id
      end
      xml.target!
    end
    alias_method :ack, :echo
  end
end
