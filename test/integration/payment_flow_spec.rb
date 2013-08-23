require 'minitest_integration_helper'
require 'mechanize'



describe 'PaymentFlow' do
  let(:sleep_duration){ 10 }

  describe 'wpf' do
    it 'creates, finds and refunds' do
      # create payment  and pay
      params = json_fixture('requests/WpfPayment').values.first
      params.delete('risk_params')
      params.delete('recurring_schedule')
      params['return_success_url'] = 'http://sankyu.com?return_success'
      params['currency'] = 'USD'



      # CREATE
      payment = Hypercharge::Payment.wpf( params )

      payment.should_redirect?.must_equal true
      payment.type.must_equal Hypercharge::Payment::Type::WpfPayment
      payment.status.must_equal Hypercharge::Payment::Status::NEW
      payment.mode.must_equal Hypercharge::Mode::TEST
      payment.amount.must_equal 50_00
      payment.currency.must_equal 'USD'
      payment.redirect_url.must_match /https:\/\/testpayment\.hypercharge\.net\/pay\/step1\/[a-f0-9]{32}/
      payment.message.must_equal 'TESTMODE: No real money will be transferred!'
      payment.technical_message.must_equal 'TESTMODE: No real money will be transferred!'
      payment.payment_methods.must_equal %w(credit_card)
      payment.should_redirect?.must_equal true


      # FIND,  before pay
      p = Hypercharge::Payment.find( payment.unique_id )
      p.type.must_equal Hypercharge::Payment::Type::WpfPayment
      p.status.must_equal Hypercharge::Payment::Status::NEW
      p.mode.must_equal Hypercharge::Mode::TEST
      p.amount.must_equal 50_00
      p.currency.must_equal 'USD'
      p.message.must_equal 'TESTMODE: No real money will be transferred!'
      p.technical_message.must_equal 'TESTMODE: No real money will be transferred!'
      p.payment_transactions.must_be_instance_of Array
      p.payment_transactions.size.must_equal 0


      # ====== Mechanize ======
      agent = Mechanize.new
      page  = agent.get payment.redirect_url

      # setp 1
      form = page.form_with :method => 'POST'
      page = form.submit


      # setp 2
      form = page.form_with :method => 'POST'
      form.field_with(:name => /card_holder/).value = 'John Doe'
      form.field_with(:name => /card_number/).value = Hypercharge::Sandbox::CreditCardNumbers::VISA_APPROVED
      form.field_with(:name => /cvv/).value = '123'
      form.field_with(:name => /expiration_date\(1i\)/).value = Time.now.year + 1
      form.submit
      # ====== Mechanize ======


      # FIND,  after pay
      payment = Hypercharge::Payment.find( payment.unique_id )
      payment.type.must_equal Hypercharge::Payment::Type::WpfPayment
      payment.status.must_equal Hypercharge::Payment::Status::APPROVED
      payment.mode.must_equal Hypercharge::Mode::TEST
      payment.amount.must_equal 50_00
      payment.currency.must_equal 'USD'
      # payment.redirect_url.must_match /https:\/\/testpayment\.hypercharge\.net\/pay\/step1\/[a-f0-9]{32}/
      payment.message.must_equal 'TESTMODE: No real money will be transferred!'
      payment.technical_message.must_equal 'TESTMODE: No real money will be transferred!'
      payment.should_redirect?.must_equal false
      payment.payment_transactions.must_be_instance_of Array

      #
      trx = payment.payment_transactions.first
      trx.must_be_instance_of Hypercharge::Transaction
      trx.status.must_equal Hypercharge::Transaction::Status::APPROVED
      trx.amount.must_equal 50_00
      trx.currency.must_equal 'USD'
      trx.unique_id.must_match /^[a-f0-9]{32}$/
      trx.transaction_id.must_match /^0AF671AF-4134-4BE7-BDF0-26E38B74106E---[a-f0-9]{40}$/
      trx.channel_token.must_equal 'a826d985097582fedf0e1459b1defb51167c3bb6'
      trx.mode.must_equal Hypercharge::Mode::TEST
      # trx.timestamp.must_equal Time.parse('2013-05-22T10:31:06Z')
      trx.descriptor.must_equal 'sankyu.com/bogus +49123456789'
      trx.customer_email.must_equal 'customer@example.com'
      trx.customer_phone.must_equal '004903000000000'
      trx.message.must_equal 'TESTMODE: No real money will be transferred!'
      trx.technical_message.must_equal 'TESTMODE: No real money will be transferred!'
      trx.billing_address.must_be_instance_of Hypercharge::Address

      billing_address = trx.billing_address
      billing_address.first_name.must_equal 'John'
      billing_address.last_name.must_equal 'Doe'
      billing_address.address1.must_equal 'Torstr. 123'
      billing_address.address2.must_equal 'HH 5. OG'
      billing_address.zip_code.must_equal '10115'
      billing_address.city.must_equal 'Berlin'
      billing_address.country_code.must_equal 'DE'

      # REFUND
      payment = Hypercharge::Payment.refund( payment.unique_id )
      payment.must_be_instance_of Hypercharge::Payment
      payment.type.must_equal Hypercharge::Payment::Type::WpfPayment
      payment.status.must_equal Hypercharge::Payment::Status::REFUNDED
      payment.unique_id.must_match /^[a-f0-9]{32}$/
      payment.amount.must_equal 50_00
      payment.currency.must_equal 'USD'
    end

    it 'cancels' do
      # create payment  and pay
      params = json_fixture('requests/WpfPayment').values.first
      params.delete('risk_params')
      params.delete('recurring_schedule')
      params['currency'] = 'USD'

      # CREATE
      payment = Hypercharge::Payment.wpf( params )

      payment.should_redirect?.must_equal true
      payment.type.must_equal Hypercharge::Payment::Type::WpfPayment
      payment.status.must_equal Hypercharge::Payment::Status::NEW

      # CANCEL
      canceled_payment = Hypercharge::Payment.cancel( payment.unique_id )
      canceled_payment.type.must_equal Hypercharge::Payment::Type::WpfPayment
      canceled_payment.status.must_equal Hypercharge::Payment::Status::CANCELED
      canceled_payment.unique_id.must_equal payment.unique_id
      canceled_payment.message.must_equal 'TESTMODE: No real money will be transferred!'
      canceled_payment.technical_message.must_equal 'TESTMODE: No real money will be transferred!'
      canceled_payment.mode.must_equal Hypercharge::Mode::TEST
      canceled_payment.amount.must_equal 50_00
      canceled_payment.currency.must_equal 'USD'
      canceled_payment.timestamp.must_be_instance_of Time
    end

    it 'captures' do
      # create payment  and pay
      params = json_fixture('requests/WpfPayment').values.first
      params.delete('risk_params')
      params.delete('recurring_schedule')
      params['currency'] = 'USD'
      params['transaction_types'] = %w(authorize)
      params['return_success_url'] = 'http://sankyu.com?return_success'

      # CREATE
      payment = Hypercharge::Payment.wpf( params )
      payment.should_redirect?.must_equal true
      payment.type.must_equal Hypercharge::Payment::Type::WpfPayment
      payment.status.must_equal Hypercharge::Payment::Status::NEW

      # ====== Mechanize ======
      agent = Mechanize.new
      page  = agent.get payment.redirect_url

      # setp 1
      form = page.form_with :method => 'POST'
      page = form.submit


      # setp 2
      form = page.form_with :method => 'POST'
      form.field_with(:name => /card_holder/).value = 'John Doe'
      form.field_with(:name => /card_number/).value = Hypercharge::Sandbox::CreditCardNumbers::VISA_APPROVED
      form.field_with(:name => /cvv/).value = '123'
      form.field_with(:name => /expiration_date\(1i\)/).value = Time.now.year + 1
      form.submit
      # ====== Mechanize ======

      # TODO: remove
      puts "~" * 80
      puts "SLEEP #{sleep_duration}"
      puts "~" * 80
      sleep sleep_duration

      payment = Hypercharge::Payment.capture( payment.unique_id )
      payment.must_be_instance_of Hypercharge::Payment
      payment.status.must_equal Hypercharge::Payment::Status::CAPTURED
      payment.type.must_equal Hypercharge::Payment::Type::WpfPayment
      payment.unique_id.must_match /^[a-f0-9]{32}$/
      payment.amount.must_equal 50_00
      payment.currency.must_equal 'USD'
      payment.timestamp.must_be_instance_of Time

      captured_trx = payment.payment_transactions.first
      captured_trx.descriptor.must_equal 'sankyu.com/bogus +49123456789'
    end

    it 'voids' do
      # create payment  and pay
      params = json_fixture('requests/WpfPayment').values.first
      params.delete('risk_params')
      params.delete('recurring_schedule')
      params['currency'] = 'USD'
      params['transaction_types'] = %w(authorize)
      params['return_success_url'] = 'http://sankyu.com?return_success'

      # CREATE
      payment = Hypercharge::Payment.wpf( params )
      payment.should_redirect?.must_equal true
      payment.type.must_equal Hypercharge::Payment::Type::WpfPayment
      payment.status.must_equal Hypercharge::Payment::Status::NEW

      # ====== Mechanize ======
      agent = Mechanize.new
      page  = agent.get payment.redirect_url

      # setp 1
      form = page.form_with :method => 'POST'
      page = form.submit


      # setp 2
      form = page.form_with :method => 'POST'
      form.field_with(:name => /card_holder/).value = 'John Doe'
      form.field_with(:name => /card_number/).value = Hypercharge::Sandbox::CreditCardNumbers::VISA_APPROVED
      form.field_with(:name => /cvv/).value = '123'
      form.field_with(:name => /expiration_date\(1i\)/).value = Time.now.year + 1
      form.submit
      # ====== Mechanize ======

      # TODO: remove
      puts "~" * 80
      puts "SLEEP #{sleep_duration}"
      puts "~" * 80
      sleep sleep_duration

      void = Hypercharge::Payment.void( payment.unique_id )
      void.must_be_instance_of Hypercharge::Payment
      void.type.must_equal Hypercharge::Payment::Type::WpfPayment
      void.status.must_equal Hypercharge::Payment::Status::VOIDED
      void.unique_id.must_match /^[a-f0-9]{32}$/
      void.timestamp.must_be_instance_of Time
    end
  end

  describe 'mobile' do
    it 'creates, finds and refunds' do
      # create payment  and pay
      params = json_fixture('requests/MobilePayment').values.first
      params.delete('risk_params')
      params.delete('recurring_schedule')
      params['currency'] = 'USD'

      # CREATE
      payment = Hypercharge::Payment.mobile( params )

      payment.should_continue_in_mobile_app?.must_equal true
      payment.type.must_equal Hypercharge::Payment::Type::MobilePayment
      payment.status.must_equal Hypercharge::Payment::Status::NEW
      payment.mode.must_equal Hypercharge::Mode::TEST
      payment.amount.must_equal 50_00
      payment.currency.must_equal 'USD'
      payment.redirect_url.must_match /https:\/\/testpayment\.hypercharge\.net\/mobile\/submit\/[a-f0-9]{32}/
      payment.cancel_url.must_match /https:\/\/testpayment\.hypercharge\.net\/mobile\/cancel\/[a-f0-9]{32}/
      payment.message.must_equal 'TESTMODE: No real money will be transferred!'
      payment.technical_message.must_equal 'TESTMODE: No real money will be transferred!'
      payment.payment_methods.must_equal %w(credit_card)


      # FIND,  before pay
      p = Hypercharge::Payment.find( payment.unique_id )
      p.type.must_equal Hypercharge::Payment::Type::MobilePayment
      p.status.must_equal Hypercharge::Payment::Status::NEW
      p.mode.must_equal Hypercharge::Mode::TEST
      p.amount.must_equal 50_00
      p.currency.must_equal 'USD'
      p.message.must_equal 'TESTMODE: No real money will be transferred!'
      p.technical_message.must_equal 'TESTMODE: No real money will be transferred!'
      p.payment_transactions.must_be_instance_of Array
      p.payment_transactions.size.must_equal 0

      # FIND,  before pay
      request_xml  = %Q[<?xml version="1.0" encoding="UTF-8"?>
<payment>
  <payment_method>credit_card</payment_method>
  <card_holder>Manfred Mann</card_holder>
  <card_number>4200000000000000</card_number>
  <cvv>123</cvv>
  <expiration_year>#{Time.now.year + 1}</expiration_year>
  <expiration_month>12</expiration_month>
</payment>]

      response_hash = Hypercharge.config.faraday.post do |req|
        req.url payment.redirect_url
        req.headers['Content-Type'] = 'text/xml'
        req.headers['Accept'] = 'text/xml'
        req.body = request_xml
      end
      # require 'debugger'
      # debugger

      # FIND,  after pay
      payment = Hypercharge::Payment.find( payment.unique_id )
      payment.type.must_equal Hypercharge::Payment::Type::MobilePayment
      payment.status.must_equal Hypercharge::Payment::Status::APPROVED
      payment.mode.must_equal Hypercharge::Mode::TEST
      payment.amount.must_equal 50_00
      payment.currency.must_equal 'USD'
      # payment.redirect_url.must_match /https:\/\/testpayment\.hypercharge\.net\/pay\/step1\/[a-f0-9]{32}/
      payment.message.must_equal 'TESTMODE: No real money will be transferred!'
      payment.technical_message.must_equal 'TESTMODE: No real money will be transferred!'
      payment.should_redirect?.must_equal false
      payment.payment_transactions.must_be_instance_of Array

      #
      trx = payment.payment_transactions.first
      trx.must_be_instance_of Hypercharge::Transaction
      trx.status.must_equal Hypercharge::Transaction::Status::APPROVED
      trx.amount.must_equal 50_00
      trx.currency.must_equal 'USD'
      trx.unique_id.must_match /^[a-f0-9]{32}$/
      trx.transaction_id.must_match /^0AF671AF-4134-4BE7-BDF0-26E38B74106E---[a-f0-9]{40}$/
      trx.channel_token.must_equal 'a826d985097582fedf0e1459b1defb51167c3bb6'
      trx.mode.must_equal Hypercharge::Mode::TEST
      # trx.timestamp.must_equal Time.parse('2013-05-22T10:31:06Z')
      trx.descriptor.must_equal 'sankyu.com/bogus +49123456789'
      trx.customer_email.must_equal 'customer@example.com'
      trx.customer_phone.must_equal '004903000000000'
      trx.message.must_equal 'TESTMODE: No real money will be transferred!'
      trx.technical_message.must_equal 'TESTMODE: No real money will be transferred!'
      trx.billing_address.must_be_instance_of Hypercharge::Address

      billing_address = trx.billing_address
      billing_address.first_name.must_equal 'John'
      billing_address.last_name.must_equal 'Doe'
      billing_address.address1.must_equal 'Torstr. 123'
      billing_address.address2.must_equal 'HH 5. OG'
      billing_address.zip_code.must_equal '10115'
      billing_address.city.must_equal 'Berlin'
      billing_address.country_code.must_equal 'DE'

      # TODO: remove
      puts "~" * 80
      puts "SLEEP #{sleep_duration}"
      puts "~" * 80
      sleep sleep_duration
      # REFUND
      payment = Hypercharge::Payment.refund( payment.unique_id )
      payment.must_be_instance_of Hypercharge::Payment
      payment.type.must_equal Hypercharge::Payment::Type::MobilePayment
      payment.status.must_equal Hypercharge::Payment::Status::REFUNDED
      payment.unique_id.must_match /^[a-f0-9]{32}$/
      payment.amount.must_equal 50_00
      payment.currency.must_equal 'USD'
    end
  end
end