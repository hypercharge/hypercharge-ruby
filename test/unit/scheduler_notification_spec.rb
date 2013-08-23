require 'minitest_helper'
require 'hypercharge/scheduler_notification'

describe Hypercharge::SchedulerNotification do


  describe 'event notification' do
    let(:merchant_password){ '313bbf7a2f9dd182f0b2879c93a1008264704be2' }
    subject{

      params = {
        "payment_transaction_unique_id" => "994f972140ba4bac19e6dfe329858c83",
        "payment_transaction_status" => "approved",
        "recurring_schedule_unique_id" => "e8fdf10b71d146c57383b5a746da5f4c",
        "recurring_event_unique_id" => "994f972140ba4bac19e6dfe329858c83",
        "notification_type" => "RecurringEvent",
        "payment_transaction_channel_token" => "edd2b8eee91584c9ce0f7b346312fae9658b92e3",
        "signature" => "54abc7119c43cdb10ce9edfa3f9aa40c2a82006888556a62f8e919898c5182150f5f32d9f5c394d5553a80a885956661b7a1218ab36877c51351f50379932e38",
        "recurring_event_due_date" => "2013-08-19",
        "payment_transaction_transaction_type" => "edd2b8eee91584c9ce0f7b346312fae9658b92e3"
      }
      Hypercharge::SchedulerNotification.new( params )
    }

    it "must create form notifications params hash" do
      n = subject

      n.unique_id.must_equal 'e8fdf10b71d146c57383b5a746da5f4c'
      n.notification_type.must_equal Hypercharge::SchedulerNotification::Type::RECURRING_EVENT
      n.signature.must_equal '54abc7119c43cdb10ce9edfa3f9aa40c2a82006888556a62f8e919898c5182150f5f32d9f5c394d5553a80a885956661b7a1218ab36877c51351f50379932e38'
      n.payment_transaction_channel_token.must_equal 'edd2b8eee91584c9ce0f7b346312fae9658b92e3'
      n.payment_transaction_unique_id.must_equal '994f972140ba4bac19e6dfe329858c83'
      n.payment_transaction_status.must_equal Hypercharge::Transaction::Status::APPROVED
      n.due_date.must_equal Date.parse('2013-08-19')
    end

    it 'must verify the signature with the merchant password' do
      subject.verify!(merchant_password)
      subject.verified?.must_equal true
    end

    it 'must generate the echo' do
      expected_echo = %Q(<?xml version="1.0" encoding="UTF-8"?>
<notification_echo>
  <unique_id>e8fdf10b71d146c57383b5a746da5f4c</unique_id>
</notification_echo>)

      echo = subject.echo.strip
      echo.must_equal expected_echo
    end
  end

  describe 'scheduler expiring' do
    let(:merchant_password){ '22743a175cd0c2c8ebe44a265bab22eb45427de8' }

    subject{
      params = {
        'recurring_schedule_unique_id' => "f433a0bf7c9681f39b82ace9d2af7e96",
        'recurring_schedule_end_date' => '2015-01-01',
        'recurring_schedule_status' => "expiring",
        'notification_type' => "RecurringSchedule",
        'signature' => "9b86a77e3095d82c78655831617f4f5b74024f68d55f233047678b04c4b02b945e317374b4912aa1c288762b57832e9dd10288492aaa338c91f79ed1eb90ba80"
      }
      Hypercharge::SchedulerNotification.new( params )
    }
    it "must create form notifications params hash" do
      n = subject

      n.unique_id.must_equal 'f433a0bf7c9681f39b82ace9d2af7e96'
      n.notification_type.must_equal Hypercharge::SchedulerNotification::Type::SCHEDULER_WILL_EXPIRE
      n.signature.must_equal '9b86a77e3095d82c78655831617f4f5b74024f68d55f233047678b04c4b02b945e317374b4912aa1c288762b57832e9dd10288492aaa338c91f79ed1eb90ba80'
      n.end_date.must_equal Date.parse('2015-01-01')
    end

    it 'must verify the signature with the merchant password' do
      subject.verify!(merchant_password)
      subject.verified?.must_equal true
    end

    it 'must generate the echo' do
      expected_echo = %Q(<?xml version="1.0" encoding="UTF-8"?>
<notification_echo>
  <unique_id>f433a0bf7c9681f39b82ace9d2af7e96</unique_id>
</notification_echo>)

      echo = subject.echo.strip
      echo.must_equal expected_echo
    end
  end
end


