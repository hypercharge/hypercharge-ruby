# encoding: UTF-8

require 'hypercharge/paginated_collection'
require 'hypercharge/scheduler/interval'
require 'hypercharge/scheduler/status'
require 'hypercharge/scheduler/type'
require 'hypercharge/api_calls/scheduler'

module Hypercharge
  #
  class Scheduler
    extend ApiCalls::Scheduler

    attr_reader :unique_id, :payment_transaction_unique_id, :amount, :currency,
                :start_date, :end_date, :interval, :timestamp,
                :expiring_notification_time, :active, :enabled

    alias_method :active?, :active
    alias_method :enabled?, :enabled


    def initialize(params)
      @unique_id                     = params['unique_id']
      @payment_transaction_unique_id = params['payment_transaction_unique_id']
      @amount                        = params['amount'].to_i
      @currency                      = params['currency']
      @start_date                    = Date.parse(params['start_date']) if params['start_date']
      @end_date                      = Date.parse(params['end_date']) if  params['end_date']
      @timestamp                     = Time.parse(params['timestamp']) if  params['timestamp']
      @interval                      = Interval.with_name(params['interval'])
      @expiring_notification_time    = params['expiring_notification_time']
      @active                        = boolify(params['active'])
      @enabled                       = boolify(params['enabled'])
    end

    def boolify(string_or_boolean)
      if string_or_boolean.is_a?(TrueClass) or string_or_boolean.is_a?(FalseClass)
        string_or_boolean
      else
        string_or_boolean == 'true'
      end
    end

    def self.notification(params)
      SchedulerNotification.new(params).tap do |n|
        n.verify!(Hypercharge.config.password)
      end
    end
  end
end