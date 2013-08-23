require 'minitest_helper'
require 'hypercharge/transaction_notification'

describe Hypercharge::TransactionNotification do

  subject{ Hypercharge::TransactionNotification.new( params ) }

  let(:params){
    {
      'signature' => '08d01ae1ebdc22b6a1a764257819bb26e9e94e8d',
      'channel_token' => '394f2ebc3646d3c017fa1e1cbc4a1e20',
      'unique_id' => 'fc6c3c8c0219730c7a099eaa540f70dc',
      'transaction_type' => 'sale3d',
      'status' => 'approved',
      'transaction_id' => '82803B4C-70CC-43BD-8B21-FD0395285B40'
    }
  }

  let(:merchant_password){ 'bogus' }

  it "must create form notifications params hash" do
    subject.signature.must_equal '08d01ae1ebdc22b6a1a764257819bb26e9e94e8d'
    subject.channel_token.must_equal '394f2ebc3646d3c017fa1e1cbc4a1e20'
    subject.unique_id.must_equal 'fc6c3c8c0219730c7a099eaa540f70dc'
    subject.transaction_type.must_equal Hypercharge::Transaction::Type::Sale3d
    subject.status.must_equal  Hypercharge::Transaction::Status::APPROVED
    subject.transaction_id.must_equal '82803B4C-70CC-43BD-8B21-FD0395285B40'
  end

  it 'must verify the signature with the merchant password' do
    subject.verify!(merchant_password)
    subject.verified?.must_equal true
  end

  it 'must generate the echo' do
    subject.echo.strip.must_equal xml_fixture('notifications/TransactionNotification_echo').strip
  end
end

