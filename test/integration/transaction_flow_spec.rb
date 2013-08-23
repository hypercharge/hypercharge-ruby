require 'minitest_integration_helper'
require 'mechanize'

describe 'TransactionFlow' do
  it 'processes authorize' do
    params =   json_fixture("requests/authorize").values.first
    params['expiration_year'] = "#{Time.now.year + 1}"
    a = Hypercharge::Transaction.authorize(channel_token,  params)

    a.transaction_type.must_equal Hypercharge::Transaction::Type::Authorize
    a.status.must_equal Hypercharge::Transaction::Status::APPROVED
    a.unique_id.must_match /^[a-f0-9]{32}$/
    a.technical_message.must_equal 'TESTMODE: No real money will be transferred!'
    a.message.must_equal 'TESTMODE: No real money will be transferred!'
    a.mode.must_equal Hypercharge::Mode::TEST
    a.timestamp.must_be_instance_of Time
    a.descriptor.must_equal 'sankyu.com/bogus +49123456789'
    a.amount.must_equal 50_00
    a.currency.must_equal 'USD'
  end

  it 'processes authorize3d async' do
    params =   json_fixture("requests/authorize3d_async").values.first
    params['expiration_year'] = "#{Time.now.year + 1}"
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

  it 'processes authorize3d sync' do
    params =   json_fixture("requests/authorize3d_sync").values.first
    params['expiration_year'] = "#{Time.now.year + 1}"
    a = Hypercharge::Transaction.authorize3d(channel_token,  params)

    a.transaction_type.must_equal Hypercharge::Transaction::Type::Authorize3d
    a.status.must_equal Hypercharge::Transaction::Status::APPROVED
    a.unique_id.must_match /^[a-f0-9]{32}$/
    a.technical_message.must_equal 'TESTMODE: No real money will be transferred!'
    a.message.must_equal 'TESTMODE: No real money will be transferred!'
    a.mode.must_equal Hypercharge::Mode::TEST
    a.timestamp.must_be_instance_of Time
    a.descriptor.must_equal 'sankyu.com/bogus +49123456789'
    a.amount.must_equal 50_00
    a.currency.must_equal 'USD'
    a.redirect_url.must_equal nil
  end


  it 'processes sale' do
    params =   json_fixture("requests/sale").values.first
    params['expiration_year'] = "#{Time.now.year + 1}"
    a = Hypercharge::Transaction.sale(channel_token,  params)

    a.transaction_type.must_equal Hypercharge::Transaction::Type::Sale
    a.status.must_equal Hypercharge::Transaction::Status::APPROVED
    a.unique_id.must_match /^[a-f0-9]{32}$/
    a.technical_message.must_equal 'TESTMODE: No real money will be transferred!'
    a.message.must_equal 'TESTMODE: No real money will be transferred!'
    a.mode.must_equal Hypercharge::Mode::TEST
    a.timestamp.must_be_instance_of Time
    a.descriptor.must_equal 'sankyu.com/bogus +49123456789'
    a.amount.must_equal 50_00
    a.currency.must_equal 'USD'
  end

  it 'processes sale3d async' do
    params =   json_fixture("requests/sale3d_async").values.first
    params['expiration_year'] = "#{Time.now.year + 1}"
    a = Hypercharge::Transaction.sale3d(channel_token,  params)

    a.transaction_type.must_equal Hypercharge::Transaction::Type::Sale3d
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

  it 'processes sale3d sync' do
    params =   json_fixture("requests/sale3d_sync").values.first
    params['expiration_year'] = "#{Time.now.year + 1}"
    a = Hypercharge::Transaction.sale3d(channel_token,  params)

    a.transaction_type.must_equal Hypercharge::Transaction::Type::Sale3d
    a.status.must_equal Hypercharge::Transaction::Status::APPROVED
    a.unique_id.must_match /^[a-f0-9]{32}$/
    a.technical_message.must_equal 'TESTMODE: No real money will be transferred!'
    a.message.must_equal 'TESTMODE: No real money will be transferred!'
    a.mode.must_equal Hypercharge::Mode::TEST
    a.timestamp.must_be_instance_of Time
    a.descriptor.must_equal 'sankyu.com/bogus +49123456789'
    a.amount.must_equal 50_00
    a.currency.must_equal 'USD'
    a.redirect_url.must_equal nil
  end

  it 'processes capture' do
    params =   json_fixture("requests/authorize").values.first
    params['expiration_year'] = "#{Time.now.year + 1}"
    a = Hypercharge::Transaction.authorize(channel_token,  params)

    a.transaction_type.must_equal Hypercharge::Transaction::Type::Authorize
    a.status.must_equal Hypercharge::Transaction::Status::APPROVED

    params =   json_fixture("requests/capture").values.first
    params['reference_id'] = a.unique_id
    params.delete('remote_ip')

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

  it 'processes refund' do
    params =   json_fixture("requests/sale").values.first
    params['expiration_year'] = "#{Time.now.year + 1}"
    a = Hypercharge::Transaction.sale(channel_token,  params)

    a.transaction_type.must_equal Hypercharge::Transaction::Type::Sale
    a.status.must_equal Hypercharge::Transaction::Status::APPROVED

    params =   json_fixture("requests/refund").values.first
    params['reference_id'] = a.unique_id

    r = Hypercharge::Transaction.refund(channel_token,  params)
    r.transaction_type.must_equal Hypercharge::Transaction::Type::Refund
    r.status.must_equal Hypercharge::Transaction::Status::APPROVED
    r.unique_id.must_match /^[a-f0-9]{32}$/
    r.technical_message.must_equal 'TESTMODE: No real money will be transferred!'
    r.message.must_equal 'TESTMODE: No real money will be transferred!'
    r.mode.must_equal Hypercharge::Mode::TEST
    r.timestamp.must_be_instance_of Time
    r.descriptor.must_equal 'sankyu.com/bogus +49123456789'
    r.amount.must_equal 50_00
    r.currency.must_equal 'USD'
  end

  it 'processes void' do
    params =   json_fixture("requests/authorize").values.first
    params['expiration_year'] = "#{Time.now.year + 1}"
    a = Hypercharge::Transaction.authorize(channel_token,  params)

    a.transaction_type.must_equal Hypercharge::Transaction::Type::Authorize
    a.status.must_equal Hypercharge::Transaction::Status::APPROVED

    params =   json_fixture("requests/void").values.first
    params['reference_id'] = a.unique_id

    c = Hypercharge::Transaction.void(channel_token,  params)
    c.transaction_type.must_equal Hypercharge::Transaction::Type::Void
    c.status.must_equal Hypercharge::Transaction::Status::APPROVED
    c.unique_id.must_match /^[a-f0-9]{32}$/
    c.technical_message.must_equal 'TESTMODE: No real money will be transferred!'
    c.message.must_equal 'TESTMODE: No real money will be transferred!'
    c.mode.must_equal Hypercharge::Mode::TEST
    c.timestamp.must_be_instance_of Time
    c.descriptor.must_equal 'sankyu.com/bogus +49123456789'
  end

  it 'processes init_recurring_sale' do
    params =   json_fixture("requests/init_recurring_sale").values.first
    params['expiration_year'] = "#{Time.now.year + 1}"
    # params['recurring_schedule']['start_date'] = "#{Time.now.year + 1}-01-01"
    params.delete('recurring_schedule')
    a = Hypercharge::Transaction.init_recurring_sale(channel_token,  params)

    a.transaction_type.must_equal Hypercharge::Transaction::Type::InitRecurringSale
    a.status.must_equal Hypercharge::Transaction::Status::APPROVED
    a.unique_id.must_match /^[a-f0-9]{32}$/
    a.technical_message.must_equal 'TESTMODE: No real money will be transferred!'
    a.message.must_equal 'TESTMODE: No real money will be transferred!'
    a.mode.must_equal Hypercharge::Mode::TEST
    a.timestamp.must_be_instance_of Time
    a.descriptor.must_equal 'sankyu.com/bogus +49123456789'
    a.amount.must_equal 50_00
    a.currency.must_equal 'USD'
  end

  it 'processes init_recurring_authorize' do
    params =   json_fixture("requests/init_recurring_authorize").values.first
    params['expiration_year'] = "#{Time.now.year + 1}"
    params.delete('recurring_schedule')
    a = Hypercharge::Transaction.init_recurring_authorize(channel_token,  params)

    a.transaction_type.must_equal Hypercharge::Transaction::Type::InitRecurringAuthorize
    a.status.must_equal Hypercharge::Transaction::Status::APPROVED
    a.unique_id.must_match /^[a-f0-9]{32}$/
    a.technical_message.must_equal 'TESTMODE: No real money will be transferred!'
    a.message.must_equal 'TESTMODE: No real money will be transferred!'
    a.mode.must_equal Hypercharge::Mode::TEST
    a.timestamp.must_be_instance_of Time
    a.descriptor.must_equal 'sankyu.com/bogus +49123456789'
    a.amount.must_equal 50_00
    a.currency.must_equal 'USD'
  end

  it 'processes recurring_sale' do
    params =   json_fixture("requests/init_recurring_sale").values.first
    params['expiration_year'] = "#{Time.now.year + 1}"
    params.delete('recurring_schedule')
    a = Hypercharge::Transaction.init_recurring_sale(channel_token,  params)

    a.transaction_type.must_equal Hypercharge::Transaction::Type::InitRecurringSale
    a.status.must_equal Hypercharge::Transaction::Status::APPROVED

    params =   json_fixture("requests/recurring_sale").values.first
    params['reference_id'] = a.unique_id

    r = Hypercharge::Transaction.recurring_sale(channel_token,  params)
    r.transaction_type.must_equal Hypercharge::Transaction::Type::RecurringSale
    r.status.must_equal Hypercharge::Transaction::Status::APPROVED
    r.unique_id.must_match /^[a-f0-9]{32}$/
    r.technical_message.must_equal 'TESTMODE: No real money will be transferred!'
    r.message.must_equal 'TESTMODE: No real money will be transferred!'
    r.mode.must_equal Hypercharge::Mode::TEST
    r.timestamp.must_be_instance_of Time
    r.descriptor.must_equal 'sankyu.com/bogus +49123456789'
    r.amount.must_equal 50_00
    r.currency.must_equal 'USD'
  end

  it 'processes ideal_sale' do
    params =   json_fixture("requests/ideal_sale").values.first
    params['currency'] = 'USD'

    a = Hypercharge::Transaction.ideal_sale(channel_token,  params)

    a.transaction_type.must_equal Hypercharge::Transaction::Type::IdealSale
    a.status.must_equal Hypercharge::Transaction::Status::PENDING_ASYNC
    a.unique_id.must_match /^[a-f0-9]{32}$/
    a.technical_message.must_equal 'TESTMODE: No real money will be transferred!'
    a.message.must_equal 'TESTMODE: No real money will be transferred!'
    a.mode.must_equal Hypercharge::Mode::TEST
    a.timestamp.must_be_instance_of Time
    a.descriptor.must_equal 'sankyu.com/bogus +49123456789'
    a.amount.must_equal 50_00
    a.currency.must_equal 'USD'
  end

  it 'processes referenced_fund_transfer' do
    params =   json_fixture("requests/sale").values.first
    params['expiration_year'] = "#{Time.now.year + 1}"
    a = Hypercharge::Transaction.sale(channel_token,  params)

    a.transaction_type.must_equal Hypercharge::Transaction::Type::Sale
    a.status.must_equal Hypercharge::Transaction::Status::APPROVED

    params =   json_fixture("requests/referenced_fund_transfer").values.first
    params['reference_id'] = a.unique_id

    r = Hypercharge::Transaction.referenced_fund_transfer(channel_token,  params)
    r.transaction_type.must_equal Hypercharge::Transaction::Type::ReferencedFundTransfer
    r.status.must_equal Hypercharge::Transaction::Status::APPROVED
    r.unique_id.must_match /^[a-f0-9]{32}$/
    r.technical_message.must_equal 'Unknown system error! Please contact support!'
    r.message.must_equal 'Transaction failed, please contact support!'
    r.mode.must_equal Hypercharge::Mode::TEST
    r.timestamp.must_be_instance_of Time
    r.descriptor.must_equal 'sankyu.com/bogus +49123456789'
    r.amount.must_equal 50_00
    r.currency.must_equal 'USD'
  end

  it 'processes debit_sale' do
    params =   json_fixture("requests/debit_sale").values.first
    params['currency'] = 'USD'
    a = Hypercharge::Transaction.debit_sale(channel_token,  params)

    a.transaction_type.must_equal Hypercharge::Transaction::Type::DebitSale
    a.status.must_equal Hypercharge::Transaction::Status::PENDING_ASYNC
    a.unique_id.must_match /^[a-f0-9]{32}$/
    a.technical_message.must_equal 'TESTMODE: No real money will be transferred!'
    a.message.must_equal 'TESTMODE: No real money will be transferred!'
    a.mode.must_equal Hypercharge::Mode::TEST
    a.timestamp.must_be_instance_of Time
    a.descriptor.must_equal 'sankyu.com/bogus +49123456789'
    a.amount.must_equal 50_00
    a.currency.must_equal 'USD'
  end

  it 'processes purchase_on_account' do
    params =   json_fixture("requests/purchase_on_account").values.first
    params['currency'] = 'USD'
    a = Hypercharge::Transaction.purchase_on_account(channel_token,  params)

    a.transaction_type.must_equal Hypercharge::Transaction::Type::PurchaseOnAccount
    a.status.must_equal Hypercharge::Transaction::Status::PENDING_ASYNC
    a.unique_id.must_match /^[a-f0-9]{32}$/
    a.technical_message.must_equal 'TESTMODE: No real money will be transferred!'
    a.message.must_equal 'TESTMODE: No real money will be transferred!'
    a.mode.must_equal Hypercharge::Mode::TEST
    a.timestamp.must_be_instance_of Time
    a.descriptor.must_equal 'sankyu.com/bogus +49123456789'
    a.amount.must_equal 50_00
    a.currency.must_equal 'USD'
    a.wire_reference_id.must_match /[0-9A-F]{10,}/
  end

  it 'processes pay_in_advance' do
    params =   json_fixture("requests/pay_in_advance").values.first
    params['currency'] = 'USD'
    a = Hypercharge::Transaction.pay_in_advance(channel_token,  params)

    a.transaction_type.must_equal Hypercharge::Transaction::Type::PayInAdvance
    a.status.must_equal Hypercharge::Transaction::Status::PENDING_ASYNC
    a.unique_id.must_match /^[a-f0-9]{32}$/
    a.technical_message.must_equal 'TESTMODE: No real money will be transferred!'
    a.message.must_equal 'TESTMODE: No real money will be transferred!'
    a.mode.must_equal Hypercharge::Mode::TEST
    a.timestamp.must_be_instance_of Time
    a.descriptor.must_equal 'sankyu.com/bogus +49123456789'
    a.amount.must_equal 50_00
    a.currency.must_equal 'USD'
    a.wire_reference_id.must_match /[0-9A-F]{10,}/
  end

  it 'processes payment_on_delivery' do
    params =   json_fixture("requests/payment_on_delivery").values.first
    params['currency'] = 'USD'
    a = Hypercharge::Transaction.payment_on_delivery(channel_token,  params)

    a.transaction_type.must_equal Hypercharge::Transaction::Type::PaymentOnDelivery
    a.status.must_equal Hypercharge::Transaction::Status::APPROVED
    a.unique_id.must_match /^[a-f0-9]{32}$/
    a.technical_message.must_equal 'TESTMODE: No real money will be transferred!'
    a.message.must_equal 'TESTMODE: No real money will be transferred!'
    a.mode.must_equal Hypercharge::Mode::TEST
    a.timestamp.must_be_instance_of Time
    a.descriptor.must_equal 'sankyu.com/bogus +49123456789'
    a.amount.must_equal 50_00
    a.currency.must_equal 'USD'
  end

  it 'processes pay_pal' do
    params =   json_fixture("requests/pay_pal").values.first
    params['currency'] = 'USD'
    a = Hypercharge::Transaction.pay_pal(channel_token,  params)

    a.transaction_type.must_equal Hypercharge::Transaction::Type::PayPal
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

  it 'processes init_recurring_debit_sale' do
    params =   json_fixture("requests/init_recurring_debit_sale").values.first
    params['currency'] = 'USD'
    params.delete('recurring_schedule')
    a = Hypercharge::Transaction.init_recurring_debit_sale(channel_token,  params)

    a.transaction_type.must_equal Hypercharge::Transaction::Type::InitRecurringDebitSale
    a.status.must_equal Hypercharge::Transaction::Status::PENDING_ASYNC
    a.unique_id.must_match /^[a-f0-9]{32}$/
    a.technical_message.must_equal 'TESTMODE: No real money will be transferred!'
    a.message.must_equal 'TESTMODE: No real money will be transferred!'
    a.mode.must_equal Hypercharge::Mode::TEST
    a.timestamp.must_be_instance_of Time
    a.descriptor.must_equal 'sankyu.com/bogus +49123456789'
    a.amount.must_equal 50_00
    a.currency.must_equal 'USD'
  end

  it 'processes init_recurring_debit_authorize' do
    params =   json_fixture("requests/init_recurring_debit_authorize").values.first
    params['currency'] = 'USD'
    params.delete('recurring_schedule')
    a = Hypercharge::Transaction.init_recurring_debit_authorize(channel_token,  params)

    a.transaction_type.must_equal Hypercharge::Transaction::Type::InitRecurringDebitAuthorize
    a.status.must_equal Hypercharge::Transaction::Status::APPROVED
    a.unique_id.must_match /^[a-f0-9]{32}$/
    a.technical_message.must_equal 'TESTMODE: No real money will be transferred!'
    a.message.must_equal 'TESTMODE: No real money will be transferred!'
    a.mode.must_equal Hypercharge::Mode::TEST
    a.timestamp.must_be_instance_of Time
    a.descriptor.must_equal 'sankyu.com/bogus +49123456789'
    a.amount.must_equal 50_00
    a.currency.must_equal 'USD'
  end

  it 'processes recurring_debit_sale' do
    params =   json_fixture("requests/init_recurring_debit_sale").values.first
    params['currency'] = 'USD'
    params.delete('recurring_schedule')
    a = Hypercharge::Transaction.init_recurring_debit_sale(channel_token,  params)

    a.transaction_type.must_equal Hypercharge::Transaction::Type::InitRecurringDebitSale
    a.status.must_equal Hypercharge::Transaction::Status::PENDING_ASYNC

    # charge
    # res = Hypercharge::Sandbox.charge_debit_sale(channel_token, a.unique_id)
    # debugger


    params =   json_fixture("requests/recurring_debit_sale").values.first
    params['reference_id'] = a.unique_id

    c = Hypercharge::Transaction.recurring_debit_sale(channel_token,  params)
    c.transaction_type.must_equal Hypercharge::Transaction::Type::RecurringDebitSale
    c.status.must_equal Hypercharge::Transaction::Status::PENDING_ASYNC
    c.unique_id.must_match /^[a-f0-9]{32}$/
    c.technical_message.must_equal 'TESTMODE: No real money will be transferred!'
    c.message.must_equal 'TESTMODE: No real money will be transferred!'
    c.mode.must_equal Hypercharge::Mode::TEST
    c.timestamp.must_be_instance_of Time
    c.descriptor.must_equal 'sankyu.com/bogus +49123456789'
    c.amount.must_equal 50_00
    c.currency.must_equal 'USD'
  end


  it 'finds a singe Transaction by unique_id' do
    params =   json_fixture("requests/sale").values.first
    params['expiration_year'] = "#{Time.now.year + 1}"
    a = Hypercharge::Transaction.sale(channel_token,  params)

    a.transaction_type.must_equal Hypercharge::Transaction::Type::Sale
    a.status.must_equal Hypercharge::Transaction::Status::APPROVED

    a = Hypercharge::Transaction.find(channel_token,  a.unique_id)
    a.transaction_type.must_equal Hypercharge::Transaction::Type::Sale
    a.status.must_equal Hypercharge::Transaction::Status::APPROVED
    a.unique_id.must_match /^[a-f0-9]{32}$/
    a.technical_message.must_equal 'TESTMODE: No real money will be transferred!'
    a.message.must_equal 'TESTMODE: No real money will be transferred!'
    a.mode.must_equal Hypercharge::Mode::TEST
    a.timestamp.must_be_instance_of Time
    a.descriptor.must_equal 'sankyu.com/bogus +49123456789'
    a.amount.must_equal 50_00
    a.currency.must_equal 'USD'
  end

  it 'gets pages of Transactions' do
    collection = Hypercharge::Transaction.page(channel_token, :page => 1)
    collection.must_be_instance_of Hypercharge::PaginatedCollection
    collection.page.must_equal 1
    collection.per_page.must_equal 100
    collection.total_count.must_be :>, 100
    collection.each do |trx|
      trx.must_be_instance_of Hypercharge::Transaction
    end
  end

  it 'iterates over all Transactions' do
    count = 0
    Hypercharge::Transaction.each(channel_token, :start_date => (Time.now - 3600*24).to_date) do |trx|
      break if count > 101
      trx.must_be_instance_of Hypercharge::Transaction
      count += 1
    end
  end
end