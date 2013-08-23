require 'minitest_helper'


describe Hypercharge::Transaction do

  let(:response_params){
    {
      'transaction_id'     => '22384df3051e42568754b45fde0fb36c',
      'unique_id'          => '5e2cbbad71d2b13432323153c208223a',
      'usage'              => 'Order-1414',
      'descriptor'         => 'descriptor one',
      'transaction_type'   => 'init_recurring_sale',
      'status'             => 'approved',
      'amount'             => '5000',
      'currency'           => 'EUR'
    }
  }

  describe 'the instance' do
    it 'gets created from response params' do
      payment = Hypercharge::Transaction.new(response_params)
      payment.transaction_type.must_equal   Hypercharge::Transaction::Type::InitRecurringSale
      payment.status.must_equal             Hypercharge::Transaction::Status::APPROVED
      payment.unique_id.must_equal          '5e2cbbad71d2b13432323153c208223a'
      payment.transaction_id.must_equal     '22384df3051e42568754b45fde0fb36c'
      payment.usage.must_equal              'Order-1414'
      payment.descriptor.must_equal         'descriptor one'
      payment.amount.must_equal             50_00
      payment.currency.must_equal           'EUR'
    end
  end

  describe 'static methods' do
    it 'creates the notification' do
      notification = Hypercharge::Transaction.notification({})
      notification.must_be_instance_of Hypercharge::TransactionNotification
    end
  end

  describe 'api requests' do
    let(:channel_token) { 'edd2b8eee91584c9ce0f7b346312fae9658b92e3' }

    it 'raises ArgumentError when required param are missing' do
      params = json_fixture('requests/authorize').values.first
      params.delete('card_number')
      lambda{ Hypercharge::Transaction.authorize(params) }.must_raise ArgumentError
    end

    it 'processes authorize' do
      stub_request(:post, /edd2b8eee91584c9ce0f7b346312fae9658b92e3/) \
        .with(:body => xml_fixture("requests/authorize"),
          :headers => {"Content-Type" => "text/xml"}) \
        .to_return(:body => xml_fixture('responses/authorize_approved'),
                   :headers => {"Content-Type" => "text/xml"})

      params =   json_fixture("requests/authorize").values.first
      a = Hypercharge::Transaction.authorize(channel_token,  params)

      a.transaction_type.must_equal Hypercharge::Transaction::Type::Authorize
      a.status.must_equal Hypercharge::Transaction::Status::APPROVED
      a.unique_id.must_match /^[a-f0-9]{32}$/
      a.technical_message.must_equal 'TESTMODE: No real money will be transferred!'
      a.message.must_equal 'TESTMODE: No real money will be transferred!'
      a.mode.must_equal Hypercharge::Mode::LIVE
      a.timestamp.must_be_instance_of Time
      a.descriptor.must_equal 'Descriptor One'
      a.amount.must_equal 50_00
      a.currency.must_equal 'USD'
      a.transaction_id.must_equal '43671'
    end

    it 'processes authorize3d async' do
      stub_request(:post, /edd2b8eee91584c9ce0f7b346312fae9658b92e3/) \
        .with(:body => xml_fixture("requests/authorize3d_async"),
          :headers => {"Content-Type" => "text/xml"}) \
        .to_return(:body => xml_fixture('responses/authorize3d_pending_async'),
          :headers => {"Content-Type" => "text/xml"})

      params =   json_fixture("requests/authorize3d_async").values.first
      a = Hypercharge::Transaction.authorize3d(channel_token,  params)

      a.transaction_type.must_equal Hypercharge::Transaction::Type::Authorize3d
      a.status.must_equal Hypercharge::Transaction::Status::PENDING_ASYNC
      a.unique_id.must_match /^[a-f0-9]{32}$/
      a.technical_message.must_equal 'TESTMODE: No real money will be transferred!'
      a.message.must_equal 'TESTMODE: No real money will be transferred!'
      a.mode.must_equal Hypercharge::Mode::TEST
      a.timestamp.must_be_instance_of Time
      a.descriptor.must_equal 'sankyu.com/bogus +49123456789'
      a.amount.must_equal 50_00
      a.currency.must_equal 'USD'
      a.redirect_url.must_match /^https:\/\/test\.hypercharge\.net\/redirect\/to_acquirer\/[a-f0-9]{32}$/
    end

    it 'processes capture' do
      stub_request(:post, /edd2b8eee91584c9ce0f7b346312fae9658b92e3/) \
        .with(:body => xml_fixture("requests/capture"),
          :headers => {"Content-Type" => "text/xml"}) \
        .to_return(:body => xml_fixture('responses/capture'),
          :headers => {"Content-Type" => "text/xml"})

      params =   json_fixture("requests/capture").values.first
      a = Hypercharge::Transaction.capture(channel_token,  params)

      c = Hypercharge::Transaction.capture(channel_token,  params)
      c.transaction_type.must_equal Hypercharge::Transaction::Type::Capture
      c.status.must_equal Hypercharge::Transaction::Status::APPROVED
      c.unique_id.must_match /^[a-f0-9]{32}$/
      c.technical_message.must_equal 'TESTMODE: No real money will be transferred!'
      c.message.must_equal 'TESTMODE: No real money will be transferred!'
      c.mode.must_equal Hypercharge::Mode::TEST
      c.timestamp.must_be_instance_of Time
      c.descriptor.must_equal 'sankyu.com/bogus +49123456789'
      c.amount.must_equal 50_00
      c.currency.must_equal 'USD'
    end


    transaction_request_spec 'authorize3d', 'authorize3d_sync'
    transaction_request_spec 'debit_sale'
    transaction_request_spec 'ideal_sale'
    transaction_request_spec 'init_recurring_authorize'
    transaction_request_spec 'init_recurring_debit_authorize'
    transaction_request_spec 'init_recurring_debit_sale'
    transaction_request_spec 'init_recurring_sale'
    transaction_request_spec 'pay_in_advance'
    transaction_request_spec 'pay_pal'
    transaction_request_spec 'payment_on_delivery'
    transaction_request_spec 'purchase_on_account'
    transaction_request_spec 'recurring_debit_sale'
    transaction_request_spec 'recurring_sale'
    transaction_request_spec 'referenced_fund_transfer'
    transaction_request_spec 'refund'
    transaction_request_spec 'sale'
    transaction_request_spec 'sale3d', 'sale3d_async'
    transaction_request_spec 'sale3d', 'sale3d_sync'
    transaction_request_spec 'void'

    it 'gets a single transaction by unique_id' do
      stub_request(:post, /reconcile/) \
        .with(:body => xml_fixture("requests/reconcile"),
          :headers => {"Content-Type" => "text/xml"}) \
        .to_return(:body => xml_fixture('responses/authorize_approved'),
          :headers => {"Content-Type" => "text/xml"})

      authorize_transaction = Hypercharge::Transaction.find('the_channel_token', '61c06cf0a03d01307dde542696cde09d')

      authorize_transaction.must_be_instance_of Hypercharge::Transaction
      authorize_transaction.transaction_type.must_equal   Hypercharge::Transaction::Type::Authorize
    end

   it 'gets a paged collection of payment_transactions with single result' do
      stub_request(:post, /reconcile\/by_date/) \
        .with(:body => "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<reconcile>\n  <page>1</page>\n  <start_date>1970-01-01</start_date>\n</reconcile>",
          :headers => {"Content-Type" => "text/xml"}) \
        .to_return(:body => xml_fixture('responses/reconcile_by_date_single_result'),
          :headers => {"Content-Type" => "text/xml"})

      collection = Hypercharge::Transaction.page('the_channel_token')

      collection.must_be_instance_of Hypercharge::PaginatedCollection
      collection.page.must_equal 1
      collection.per_page.must_equal 100
      collection.total_count.must_equal 1
      collection.pages_count.must_equal 1
      collection.next_page?.must_equal false
      collection.next_page.must_equal nil
      collection.size.must_equal 1

      sale0 = collection[0]
      sale0.must_be_instance_of Hypercharge::Transaction
      sale0.transaction_type.must_equal Hypercharge::Transaction::Type::Authorize
      sale0.status.must_equal Hypercharge::Transaction::Status::APPROVED
      sale0.mode.must_equal Hypercharge::Mode::TEST
      sale0.amount.must_equal 50_00
      sale0.currency.must_equal 'USD'
      sale0.unique_id.must_equal '25a1464848387259c63200a99f466e8c'
      sale0.transaction_id.must_equal '43671---775fff20a51e01303d37542696cde09d'
      sale0.descriptor.must_equal 'sankyu.com/bogus +49123456789'
      sale0.timestamp.must_equal Time.parse('2013-05-22 15:00:26 UTC')
      sale0.message.must_equal 'TESTMODE: No real money will be transferred!'
      sale0.technical_message.must_equal 'TESTMODE: No real money will be transferred!'
      sale0.error.must_equal nil
    end

    it 'gets a paged collection of payment_transactions with 298 results' do
      stub_request(:post, /reconcile\/by_date/) \
        .with(:body => "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<reconcile>\n  <page>1</page>\n  <start_date>1970-01-01</start_date>\n</reconcile>",
          :headers => {"Content-Type" => "text/xml"}) \
        .to_return(:body => xml_fixture('responses/reconcile_by_date_page_1'),
          :headers => {"Content-Type" => "text/xml"})

      collection = Hypercharge::Transaction.page('the_channel_token')

      collection.must_be_instance_of Hypercharge::PaginatedCollection
      collection.page.must_equal 1
      collection.per_page.must_equal 100
      collection.total_count.must_equal 298
      collection.pages_count.must_equal 3
      collection.next_page?.must_equal true
      collection.next_page.must_equal 2
      collection.size.must_equal 100

      sale0 = collection[0]
      sale0.must_be_instance_of Hypercharge::Transaction
      sale0.transaction_type.must_equal Hypercharge::Transaction::Type::Sale
      sale0.status.must_equal Hypercharge::Transaction::Status::APPROVED
      sale0.mode.must_equal Hypercharge::Mode::TEST
      sale0.amount.must_equal 50_00
      sale0.currency.must_equal 'USD'
      sale0.unique_id.must_equal '33d0ea86616a89d091a300c25ac683cf'
      sale0.transaction_id.must_equal '0AF671AF-4134-4BE7-BDF0-26E38B74106E---d8981080a4f701303cf4542696cde09d'
      sale0.descriptor.must_equal 'sankyu.com/bogus +49123456789'
      sale0.timestamp.must_equal Time.parse('2013-05-22 10:31:06 UTC')
      sale0.message.must_equal 'TESTMODE: No real money will be transferred!'
      sale0.technical_message.must_equal 'TESTMODE: No real money will be transferred!'
      sale0.error.must_equal nil

      sale1 = collection[1]
      sale1.must_be_instance_of Hypercharge::Transaction
      sale1.unique_id.must_equal '2eb1794bc9ede30a3a3dc0f110360636'

      sale2 = collection[2]
      sale2.must_be_instance_of Hypercharge::Transaction
      sale2.unique_id.must_equal '13ab659441898a28049baa603630cf85'
    end

    it 'iterates over all results in all pages' do
      stub_request(:post, /reconcile\/by_date/) \
        .to_return(:body => xml_fixture('responses/reconcile_by_date_page_1'),
          :headers => {"Content-Type" => "text/xml"}).then \
        .to_return(:body => xml_fixture('responses/reconcile_by_date_page_2'),
          :headers => {"Content-Type" => "text/xml"}).then \
        .to_return(:body => xml_fixture('responses/reconcile_by_date_page_3'),
          :headers => {"Content-Type" => "text/xml"})

      count = 0
      Hypercharge::Transaction.each('the_channel_token') do |payment_transaction|
        payment_transaction.must_be_instance_of Hypercharge::Transaction
        count += 1
      end
      count.must_equal 298
    end
  end
end
