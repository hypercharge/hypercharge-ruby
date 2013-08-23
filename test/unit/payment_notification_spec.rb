require 'minitest_helper'
require 'hypercharge/payment_notification'

describe Hypercharge::PaymentNotification do

  subject{ Hypercharge::PaymentNotification.new( params ) }

  let(:params){
    {
      'signature' => '3d82fef85cb60e289d52c3854b97e832d4a2e95ad205e79d9cb4dc7439025cf0aabfd5b88e77d9260c5c4aa7434e01c5f00fc9c2487407c48efeddf6159ab526',
      'payment_transaction_channel_token' => 'e9fd7a957845450fb7ab9dccb498b6e1f6e1e3aa',
      'payment_transaction_unique_id' => 'bad08183a9ec545daf0f24c48361aa10',
      'payment_transaction_id' => 'mtid201104081447161135536962',
      'payment_transaction_transaction_type' => 'sale',
      'payment_status' => 'approved',
      'payment_unique_id' => '26aa150ee68b1b2d6758a0e6c44fce4c',
      'notification_type' => 'WpfPayment'
    }
  }

  let(:merchant_password){ 'b5af4c9cf497662e00b78550fd87e65eb415f42f' }

  it "must create form notifications params hash" do
    subject.signature.must_equal '3d82fef85cb60e289d52c3854b97e832d4a2e95ad205e79d9cb4dc7439025cf0aabfd5b88e77d9260c5c4aa7434e01c5f00fc9c2487407c48efeddf6159ab526'
    subject.payment_transaction_channel_token.must_equal 'e9fd7a957845450fb7ab9dccb498b6e1f6e1e3aa'
    subject.payment_transaction_unique_id.must_equal 'bad08183a9ec545daf0f24c48361aa10'
    subject.payment_transaction_id.must_equal 'mtid201104081447161135536962'
    subject.payment_transaction_transaction_type.must_equal 'sale'
    subject.payment_status.must_equal  Hypercharge::Payment::Status::APPROVED
    subject.payment_unique_id.must_equal '26aa150ee68b1b2d6758a0e6c44fce4c'
    subject.notification_type.must_equal Hypercharge::Payment::Type::WpfPayment
  end

  it 'must verify the signature with the merchant password' do
    subject.verify!(merchant_password)
    subject.verified?.must_equal true
  end

  it 'must generate the echo' do
    subject.echo.strip.must_equal xml_fixture('notifications/PaymentNotification_echo').strip
  end
end

