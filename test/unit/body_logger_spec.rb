require 'minitest_helper'
require 'hypercharge/middleware/body_logger'
require 'logger'

describe Hypercharge::Middleware::BodyLogger do

  let(:io) { StringIO.new }
  let(:body_logger){ Hypercharge::Middleware::BodyLogger.new(stub(:call => stub(:on_complete)), Logger.new(io)) }

  describe 'request' do
    it 'masks credit card numbers in xml' do
      env = {:body => xml_fixture('requests/sale'), :request_headers => [], :response_headers => []}
      body_logger.call(env)
      io.string.wont_match /4200000000000000/
      io.string.must_match /<card_number>xxxx-xxxx-xxxx-xxx/
    end

    it 'masks 13 digit credit card numbers in string' do
      env = {:body => 'card number: 4200000000000', :request_headers => [], :response_headers => []}
      body_logger.call(env)
      io.string.wont_match /4200000000000/
      io.string.must_match /card number: xxxx-xxxx-xxxx-xxx/
    end

    it 'masks 16 digit credit card numbers in string' do
      env = {:body => '4200000000000000', :request_headers => [], :response_headers => []}
      body_logger.call(env)
      io.string.wont_match /4200000000000000/
      io.string.must_match /xxxx-xxxx-xxxx-xxx/
    end


    it 'masks cvv' do
      env = {:body => xml_fixture('requests/sale'), :request_headers => [], :response_headers => []}
      body_logger.call(env)
      io.string.wont_match /<cvv>123/
      io.string.must_match /<cvv>xxx/
    end

    it 'masks expiration_month' do
      env = {:body => xml_fixture('requests/sale'), :request_headers => [], :response_headers => []}
      body_logger.call(env)
      io.string.wont_match /<expiration_month>2/
      io.string.must_match /<expiration_month>xx/
    end

    it 'masks expiration_year' do
      env = {:body => xml_fixture('requests/sale'), :request_headers => [], :response_headers => []}
      body_logger.call(env)
      io.string.wont_match /<expiration_year>2010/
      io.string.must_match /<expiration_year>xxxx/
    end

    it 'masks bank_account_number' do
      env = {:body => xml_fixture('requests/debit_sale'), :request_headers => [], :response_headers => []}
      body_logger.call(env)
      io.string.wont_match /<bank_account_number>9290701/
      io.string.must_match /<bank_account_number>xxxxxxxxxx/
    end
  end

  describe 'response' do
    it 'masks credit card numbers in xml' do
      env = {:body => xml_fixture('requests/sale'), :request_headers => [], :response_headers => []}
      body_logger.on_complete(env)
      io.string.wont_match /4200000000000000/
      io.string.must_match /<card_number>xxxx-xxxx-xxxx-xxx/
    end

    it 'masks 13 digit credit card numbers in string' do
      env = {:body => 'card number: 4200000000000', :request_headers => [], :response_headers => []}
      body_logger.on_complete(env)
      io.string.wont_match /4200000000000/
      io.string.must_match /card number: xxxx-xxxx-xxxx-xxx/
    end

    it 'masks 16 digit credit card numbers in string' do
      env = {:body => '4200000000000000', :request_headers => [], :response_headers => []}
      body_logger.on_complete(env)
      io.string.wont_match /4200000000000000/
      io.string.must_match /xxxx-xxxx-xxxx-xxx/
    end


    it 'masks cvv' do
      env = {:body => xml_fixture('requests/sale'), :request_headers => [], :response_headers => []}
      body_logger.on_complete(env)
      io.string.wont_match /<cvv>123/
      io.string.must_match /<cvv>xxx/
    end

    it 'masks expiration_month' do
      env = {:body => xml_fixture('requests/sale'), :request_headers => [], :response_headers => []}
      body_logger.on_complete(env)
      io.string.wont_match /<expiration_month>2/
      io.string.must_match /<expiration_month>xx/
    end

    it 'masks expiration_year' do
      env = {:body => xml_fixture('requests/sale'), :request_headers => [], :response_headers => []}
      body_logger.on_complete(env)
      io.string.wont_match /<expiration_year>2010/
      io.string.must_match /<expiration_year>xxxx/
    end

    it 'masks bank_account_number' do
      env = {:body => xml_fixture('requests/debit_sale'), :request_headers => [], :response_headers => []}
      body_logger.on_complete(env)
      io.string.wont_match /<bank_account_number>9290701/
      io.string.must_match /<bank_account_number>xxxxxxxxxx/
    end
  end
end