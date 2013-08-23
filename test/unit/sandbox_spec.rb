require 'minitest_helper'



describe Hypercharge::Sandbox do
  let(:channel_token){ 'aa133d10618549b88d11e2ae8160081e' }
  let(:unique_id){ '5c8f862e504746b982c4b546e9327834' }

  it 'creates a chargeback' do
    stub_request(:post, %r[/chargeback/#{channel_token}/#{unique_id}]) \
      .to_return(:body => xml_fixture('responses/create_chargeback'),
        :headers => {"Content-Type" => "text/xml"})

    payment_transaction = Hypercharge::Sandbox.create_chargeback(channel_token, unique_id)
    payment_transaction.must_be_instance_of Hypercharge::Transaction
    payment_transaction.status.must_equal Hypercharge::Transaction::Status::CHARGEBACKED
  end

  it 'creates pre_arbitration' do
    stub_request(:post, %r[/pre_arbitration/#{channel_token}/#{unique_id}]) \
      .to_return(:body => xml_fixture('responses/create_pre_arbitration'),
        :headers => {"Content-Type" => "text/xml"})

    payment_transaction = Hypercharge::Sandbox.create_pre_arbitration(channel_token, unique_id)
    payment_transaction.must_be_instance_of Hypercharge::Transaction
    payment_transaction.status.must_equal Hypercharge::Transaction::Status::PRE_ARBITRATED
  end

  it 'creates chargeback_reversal' do
    stub_request(:post, %r[/chargeback_reversal/#{channel_token}/#{unique_id}]) \
      .to_return(:body => xml_fixture('responses/create_chargeback_reversal'),
        :headers => {"Content-Type" => "text/xml"})

    payment_transaction = Hypercharge::Sandbox.create_chargeback_reversal(channel_token, unique_id)
    payment_transaction.must_be_instance_of Hypercharge::Transaction
    payment_transaction.status.must_equal Hypercharge::Transaction::Status::CHARGEBACK_REVERSED
  end

  it 'creates retrieval_request' do
    stub_request(:post, %r[/retrieval/#{channel_token}/#{unique_id}]) \
      .to_return(:body => xml_fixture('responses/create_retrieval_request'),
        :headers => {"Content-Type" => "text/xml"})

    payment_transaction = Hypercharge::Sandbox.create_retrieval_request(channel_token, unique_id)
    payment_transaction.must_be_instance_of Hypercharge::Transaction
    payment_transaction.status.must_equal Hypercharge::Transaction::Status::APPROVED
  end

  it 'creates deposit' do
    stub_request(:post, %r[/deposit/#{channel_token}/#{unique_id}]) \
      .to_return(:body => xml_fixture('responses/create_deposit'),
        :headers => {"Content-Type" => "text/xml"})

    payment_transaction = Hypercharge::Sandbox.create_deposit(channel_token, unique_id)
    payment_transaction.must_be_instance_of Hypercharge::Transaction
    payment_transaction.status.must_equal Hypercharge::Transaction::Status::APPROVED
  end

  it 'creates debit_chargeback' do
    stub_request(:post, %r[/debit_chargeback/#{channel_token}/#{unique_id}]) \
      .to_return(:body => xml_fixture('responses/create_debit_chargeback'),
        :headers => {"Content-Type" => "text/xml"})

    payment_transaction = Hypercharge::Sandbox.create_debit_chargeback(channel_token, unique_id)
    payment_transaction.must_be_instance_of Hypercharge::Transaction
    payment_transaction.status.must_equal Hypercharge::Transaction::Status::CHARGEBACKED
  end

  it 'reject_debit_sale' do
    stub_request(:post, %r[/reject/#{channel_token}/#{unique_id}]) \
      .to_return(:body => xml_fixture('responses/create_rejected_debit_sale'),
        :headers => {"Content-Type" => "text/xml"})

    payment_transaction = Hypercharge::Sandbox.reject_debit_sale(channel_token, unique_id)
    payment_transaction.must_be_instance_of Hypercharge::Transaction
    payment_transaction.status.must_equal Hypercharge::Transaction::Status::REJECTED
  end

  it 'charge_debit_sale' do
    stub_request(:post, %r[/charge/#{channel_token}/#{unique_id}]) \
      .to_return(:body => xml_fixture('responses/debit_sale'),
        :headers => {"Content-Type" => "text/xml"})

    payment_transaction = Hypercharge::Sandbox.charge_debit_sale(channel_token, unique_id)
    payment_transaction.must_be_instance_of Hypercharge::Transaction
    payment_transaction.status.must_equal Hypercharge::Transaction::Status::APPROVED
  end

  describe 'CreditCardNumbers' do
    subject{ Hypercharge::Sandbox::CreditCardNumbers }

    specify{ subject::VISA_APPROVED.must_equal 4200000000000000 }
    specify{ subject::VISA_DECLINED.must_equal 4111111111111111 }

    specify{ subject::MASTER_CARD_APPROVED.must_equal 5555555555554444 }
    specify{ subject::MASTER_CARD_DECLINED.must_equal 5105105105105100 }

    specify{ subject::THREE_D_SECURE_ENROLLED.must_equal 4711100000000000 }
    specify{ subject::THREE_D_SECURE_FAILING_AUTHENTICATION.must_equal 4012001037461114 }
    specify{ subject::THREE_D_SECURE_UNAVAILABLE.must_equal 4200000000000000 }
    specify{ subject::THREE_D_SECURE_ERROR_IN_STEP_1.must_equal 4012001037484447 }
    specify{ subject::THREE_D_SECURE_ERROR_IN_STEP_2.must_equal 4012001036273338 }
  end

  describe 'BankAccountNumbers' do
    subject{ Hypercharge::Sandbox::BankAccountNumbers }

    specify{ subject::APPROVED.must_equal 1234567890 }
    specify{ subject::DECLINED.must_equal 2345678901 }
    specify{ subject::ERROR.must_equal    3456789012 }
  end

end