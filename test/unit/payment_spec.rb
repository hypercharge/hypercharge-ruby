require 'minitest_helper'
require 'openssl'

describe Hypercharge::Payment do

  let(:wpf_params){ json_fixture('requests/WpfPayment').fetch('payment') }

  describe 'the instance' do
    it 'gets created from response params' do
      payment = Hypercharge::Payment.new(json_fixture('responses/WpfPayment_new').fetch('payment') )
      payment.type.must_equal               Hypercharge::Payment::Type::WpfPayment
      payment.status.must_equal             Hypercharge::Payment::Status::NEW
      payment.unique_id.must_equal          'eabcb7a41044e764746b0c7e32c1e9d1'
      payment.transaction_id.must_equal     'wev238f328nc'
      payment.technical_message.must_equal  'TESTMODE: No real money will be transferred!'
      payment.message.must_equal            'TESTMODE: No real money will be transferred!'
      payment.mode.must_equal               Hypercharge::Mode::TEST
      payment.timestamp.must_equal          Time.parse('2011-04-19T15:00:11Z')
      payment.amount.must_equal             50_00
      payment.currency.must_equal           'EUR'
      payment.redirect_url.must_equal       'https://testpayment.hypercharge.net/pay/step1/eabcb7a41044e764746b0c7e32c1e9d1'
      payment.payment_methods.must_equal    ["credit_card"]
    end
  end

  describe 'static methods' do
    it 'creates the notification' do
      notification = Hypercharge::Payment.notification({})
      notification.must_be_instance_of Hypercharge::PaymentNotification
    end
  end

  describe 'api calls' do
    it 'raises ArgumentError when required param are missing' do
       stub_request(:post, /payment/) \
        .to_return(:body => xml_fixture('responses/MobilePayment_new'),
                   :headers => {"Content-Type" => "text/xml"})
      # wont raise
      Hypercharge::Payment.wpf(wpf_params)

      wpf_params.delete('amount')

      lambda{ Hypercharge::Payment.wpf(wpf_params) }.must_raise Hypercharge::Errors::InputDataError
    end

    it "creates the wpf request" do
      stub_request(:post, /payment/) \
        .with(:body => xml_fixture('requests/WpfPayment'),
          :headers => {"Content-Type" => "text/xml"}) \
        .to_return(:body => xml_fixture('responses/WpfPayment_new'),
                   :headers => {"Content-Type" => "text/xml"})

      Hypercharge::Payment.wpf( wpf_params )
    end


    it "creates the mobile request" do
      stub_request(:post, /payment/) \
        .with(:body => xml_fixture('requests/MobilePayment'),
          :headers => {"Content-Type" => "text/xml"}) \
        .to_return(:body => xml_fixture('responses/MobilePayment_new'),
                   :headers => {"Content-Type" => "text/xml"})

      params = json_fixture('requests/MobilePayment').values.first

      mobile = Hypercharge::Payment.mobile( params )
      mobile.should_continue_in_mobile_app?.must_equal true
      mobile.type.must_equal Hypercharge::Payment::Type::MobilePayment
      mobile.status.must_equal Hypercharge::Payment::Status::NEW
      mobile.mode.must_equal Hypercharge::Mode::TEST
      mobile.amount.must_equal 50_00
      mobile.currency.must_equal 'USD'
      mobile.redirect_url.must_match /https:\/\/testpayment\.hypercharge\.net\/mobile\/submit\/[a-f0-9]{32}/
      mobile.cancel_url.must_match /https:\/\/testpayment\.hypercharge\.net\/mobile\/cancel\/[a-f0-9]{32}/
      mobile.message.must_equal 'TESTMODE: No real money will be transferred!'
      mobile.technical_message.must_equal 'TESTMODE: No real money will be transferred!'
      mobile.payment_methods.must_equal %w(credit_card direct_debit)

    end

    it "creates the capture" do
      stub_request(:post, /payment\/capture/) \
        .with(:body => xml_fixture('requests/WpfPayment_capture'),
          :headers => {"Content-Type" => "text/xml"}) \
        .to_return(:body => xml_fixture('responses/WpfPayment_captured'),
                   :headers => {"Content-Type" => "text/xml"})

      capture = Hypercharge::Payment.capture( '26aa150ee68b1b2d6758a0e6c44fce4c' )
      capture.must_be_instance_of Hypercharge::Payment
      capture.type.must_equal Hypercharge::Payment::Type::WpfPayment
      capture.status.must_equal Hypercharge::Payment::Status::CAPTURED
      capture.unique_id.must_match /^[a-f0-9]{32}$/
      capture.amount.must_equal 50_00
      capture.currency.must_equal 'USD'
      capture.timestamp.must_be_instance_of Time

    end

    it "creates the cancel" do
      stub_request(:post, /payment\/cancel/) \
        .with(:body => xml_fixture('requests/WpfPayment_cancel'),
          :headers => {"Content-Type" => "text/xml"}) \
        .to_return(:body => xml_fixture('responses/WpfPayment_cancel'),
                   :headers => {"Content-Type" => "text/xml"})

      canceled_payment = Hypercharge::Payment.cancel( '26aa150ee68b1b2d6758a0e6c44fce4c' )
      canceled_payment.type.must_equal Hypercharge::Payment::Type::WpfPayment
      canceled_payment.status.must_equal Hypercharge::Payment::Status::CANCELED
      canceled_payment.unique_id.must_equal 'a3d624f0ae1f412ac4887b1e25698c9f'
      canceled_payment.message.must_equal 'TESTMODE: No real money will be transferred!'
      canceled_payment.technical_message.must_equal 'TESTMODE: No real money will be transferred!'
      canceled_payment.mode.must_equal Hypercharge::Mode::TEST
      canceled_payment.amount.must_equal 50_00
      canceled_payment.currency.must_equal 'USD'
      canceled_payment.timestamp.must_be_instance_of Time

    end

    it "creates the refund" do
      stub_request(:post, /payment\/refund/) \
        .with(:body => xml_fixture('requests/WpfPayment_refund'),
          :headers => {"Content-Type" => "text/xml"}) \
        .to_return(:body => xml_fixture('responses/WpfPayment_refunded'),
                   :headers => {"Content-Type" => "text/xml"})

      payment = Hypercharge::Payment.refund( '26aa150ee68b1b2d6758a0e6c44fce4c' )
      payment.must_be_instance_of Hypercharge::Payment
      payment.type.must_equal Hypercharge::Payment::Type::WpfPayment
      payment.status.must_equal Hypercharge::Payment::Status::REFUNDED
      payment.unique_id.must_match /^[a-f0-9]{32}$/
      payment.amount.must_equal 50_00
      payment.currency.must_equal 'USD'

    end

    it "creates the void" do
      stub_request(:post, /payment\/void/) \
        .with(:body => xml_fixture('requests/WpfPayment_void'),
          :headers => {"Content-Type" => "text/xml"}) \
        .to_return(:body => xml_fixture('responses/WpfPayment_voided'),
                   :headers => {"Content-Type" => "text/xml"})

      payment = Hypercharge::Payment.void( '26aa150ee68b1b2d6758a0e6c44fce4c' )

      payment.must_be_instance_of Hypercharge::Payment
      payment.type.must_equal Hypercharge::Payment::Type::WpfPayment
      payment.status.must_equal Hypercharge::Payment::Status::VOIDED
      payment.unique_id.must_match /^[a-f0-9]{32}$/
      payment.amount.must_equal 50_00
      payment.currency.must_equal 'USD'
    end

    it "finds by unique_id" do
      stub_request(:post, /payment\/reconcile/) \
        .with(:body => xml_fixture('requests/reconcile'),
          :headers => {"Content-Type" => "text/xml"}) \
        .to_return(:body => xml_fixture('responses/WpfPayment_find'),
                   :headers => {"Content-Type" => "text/xml"})

      payment = Hypercharge::Payment.find( '61c06cf0a03d01307dde542696cde09d' )
      payment.type.must_equal Hypercharge::Payment::Type::WpfPayment
      payment.status.must_equal Hypercharge::Payment::Status::APPROVED
      payment.mode.must_equal Hypercharge::Mode::TEST
      payment.amount.must_equal 50_00
      payment.currency.must_equal 'USD'
      payment.message.must_equal 'TESTMODE: No real money will be transferred!'
      payment.technical_message.must_equal 'TESTMODE: No real money will be transferred!'
      payment.should_redirect?.must_equal false
      payment.payment_transactions.must_be_instance_of Array
      # payment_transactions
      trx = payment.payment_transactions.first
      trx.must_be_instance_of Hypercharge::Transaction
      trx.status.must_equal Hypercharge::Transaction::Status::APPROVED
      trx.amount.must_equal 50_00
      trx.currency.must_equal 'USD'
      trx.unique_id.must_match /^[a-f0-9]{32}$/
      trx.transaction_id.must_match /^0AF671AF-4134-4BE7-BDF0-26E38B74106E---[a-f0-9]{32}$/
      trx.channel_token.must_equal 'a826d985097582fedf0e1459b1defb51167c3bb6'
      trx.mode.must_equal Hypercharge::Mode::TEST
      trx.timestamp.must_equal Time.parse('2013-05-22T10:31:06Z')
      trx.descriptor.must_equal 'sankyu.com/bogus +49123456789'
      trx.customer_email.must_equal 'customer@example.com'
      trx.customer_phone.must_equal '004903000000000'
      trx.message.must_equal 'TESTMODE: No real money will be transferred!'
      trx.technical_message.must_equal 'TESTMODE: No real money will be transferred!'
      trx.billing_address.must_be_instance_of Hypercharge::Address
      # billing_address
      billing_address = trx.billing_address
      billing_address.first_name.must_equal 'John'
      billing_address.last_name.must_equal 'Doe'
      billing_address.address1.must_equal 'Torstr. 123'
      billing_address.address2.must_equal 'HH 5. OG'
      billing_address.zip_code.must_equal '10115'
      billing_address.city.must_equal 'Berlin'
      billing_address.country_code.must_equal 'DE'
    end

  end

  describe 'reponse' do
    it 'creates Payment when successful' do
      # webmock
      stub_request(:post, /hypercharge/) \
        .to_return(:body => xml_fixture('responses/WpfPayment_new'),
                   :headers => {"Content-Type" => "text/xml"})


      payment = Hypercharge::Payment.wpf(wpf_params)

      payment.status.must_equal             Hypercharge::Payment::Status::NEW
      payment.type.must_equal               Hypercharge::Payment::Type::WpfPayment
      payment.mode.must_equal               Hypercharge::Mode::TEST
      payment.unique_id.must_equal          'eabcb7a41044e764746b0c7e32c1e9d1'
      payment.transaction_id.must_equal     'wev238f328nc'
      payment.technical_message.must_equal  'TESTMODE: No real money will be transferred!'
      payment.message.must_equal            'TESTMODE: No real money will be transferred!'
      payment.timestamp.must_equal           Time.parse('2011-04-19T15:00:11Z')
      payment.amount.must_equal              50_00
      payment.currency.must_equal           'USD'
      payment.redirect_url.must_equal       'https://testpayment.hypercharge.net/pay/step1/eabcb7a41044e764746b0c7e32c1e9d1'
      payment.error.must_equal              nil
    end

    it 'creates Payment with SystemError error' do
      # webmock
      stub_request(:post, /hypercharge/) \
        .to_return(:body => xml_fixture('responses/WpfPayment_error'),
                   :headers => {"Content-Type" => "text/xml"})


      payment = Hypercharge::Payment.wpf(wpf_params)

      payment.status.must_equal                  Hypercharge::Payment::Status::ERROR
      payment.mode.must_equal                    nil
      payment.type.must_equal                    nil
      payment.unique_id.must_equal               nil
      payment.transaction_id.must_equal          nil
      payment.technical_message.must_equal       'Unknown system error. Please contact support.'
      payment.message.must_equal                 'Transaction failed, please contact support!'
      payment.timestamp.must_equal               nil
      payment.amount.must_equal                  nil
      payment.currency.must_equal                nil
      payment.redirect_url.must_equal            nil
      payment.error.must_be_instance_of          Hypercharge::Errors::SystemError
      payment.error.status_code.must_equal       100
      payment.error.message.must_equal           'Transaction failed, please contact support!'
      payment.error.technical_message.must_equal 'Unknown system error. Please contact support.'
    end
  end

  describe 'errors' do
    it 'must let Faraday handle OpenSSL::SSL::SSLError' do
      stub_request(:post, /hypercharge/).to_raise(OpenSSL::SSL::SSLError)
      lambda{ Hypercharge::Payment.wpf(wpf_params) }.must_raise Faraday::Error::ConnectionFailed
    end

    it 'must let Faraday handle  TimeoutError' do
      stub_request(:post, /hypercharge/).to_raise(TimeoutError)
      lambda{ Hypercharge::Payment.wpf(wpf_params) }.must_raise Faraday::Error::TimeoutError
    end

    it 'must map Faraday::Error::ParsingError to Hypercharge::ResponseError' do
      stub_request(:post, /hypercharge/).to_raise(Faraday::Error::ParsingError)
      lambda{ Hypercharge::Payment.wpf(wpf_params) }.must_raise Hypercharge::Errors::ResponseError

      stub_request(:post, /hypercharge/) \
        .to_return(:body => "This is not XML!")

      lambda{ Hypercharge::Payment.wpf(wpf_params) }.must_raise Hypercharge::Errors::ResponseError
    end

    it 'raises Hypercharge::Errors::ResponseError when response root ne payment' do
      stub_request(:post, /hypercharge/).to_return(:body => "<a><b>abc</b></a>")
      lambda{ Hypercharge::Payment.wpf(wpf_params) }.must_raise Hypercharge::Errors::ResponseError

    end

    it 'raises Hypercharge::Errors::ResponseError on empty response' do
      stub_request(:post, /hypercharge/).to_return(:body => nil)
      lambda{ Hypercharge::Payment.wpf(wpf_params) }.must_raise Hypercharge::Errors::ResponseError

      stub_request(:post, /hypercharge/) \
        .to_return(:body => '')

      lambda{ Hypercharge::Payment.wpf(wpf_params) }.must_raise Hypercharge::Errors::ResponseError
    end
  end
end