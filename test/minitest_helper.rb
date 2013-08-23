# encoding: utf-8



require 'rubygems'
require 'bundler/setup'
require 'minitest/autorun'
require 'hypercharge'
require 'hypercharge/schema/fixture'
require 'webmock/minitest'
require 'mocha/setup'


class MiniTest::Spec
  # didn't work with minitest 5.x without this line
  include WebMock::API

  def self.transaction_request_spec(request_method, fixture_name = nil)

    fixture_name = request_method if fixture_name.nil?

    it "creates the #{request_method} request" do
      stub_request(:post, /edd2b8eee91584c9ce0f7b346312fae9658b92e3/) \
        .with(:body => xml_fixture("requests/#{fixture_name}"),
              :headers => {"Content-Type" => "text/xml"}) \
        .to_return(:body => xml_fixture("responses/#{fixture_name}"),
                   :headers => {"Content-Type" => "text/xml"})

      params =   json_fixture("requests/#{fixture_name}").values.first

      Hypercharge::Transaction.send(request_method,
        'edd2b8eee91584c9ce0f7b346312fae9658b92e3', params)
    end
  end

  # # faraday
  # def faraday_stub_request(conn, adapter_class = Faraday::Adapter::Test, &stubs_block)
  #   adapter_handler = conn.builder.handlers.find {|h| h.klass < Faraday::Adapter }
  #   conn.builder.swap(adapter_handler, adapter_class, &stubs_block)
  # end


  def xml_fixture(path)
    Hypercharge::Schema::Fixture.xml(path)
  end

  def json_fixture(path)
    Hypercharge::Schema::Fixture.json(path)
  end

  before do
    Hypercharge.configure do |config|
      config.login    = 'testlogin'
      config.password = 'testpassword'
      config.env      = Hypercharge::Env::Sandbox


      config.reset_defaults!
      # config.faraday do |f|
      #   # f.response :body_logger
      # end
    end

    WebMock.reset!
  end
end