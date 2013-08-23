# encoding: utf-8

require 'rubygems'
require 'bundler/setup'
require 'minitest/autorun'
require 'hypercharge'


begin
  config = JSON.parse(IO.read(File.expand_path('../integration_test_config.json', __FILE__)))
rescue
  fail %Q'

    You need to sign-up at https://secure.sankyu.com/ and provide credentails in
    test/integration_test_config.json
    see test/integration_test_config.json.example

    '
end



class MiniTest::Spec
  # def config
  # end
  let(:config){ JSON.parse(IO.read(File.expand_path('../integration_test_config.json', __FILE__))) }
  let(:channel_token){ config['channel_token'] }

  def xml_fixture(path)
    Hypercharge::Schema::Fixture.xml(path)
  end

  def json_fixture(path)
    Hypercharge::Schema::Fixture.json(path)
  end

  before do
    Hypercharge.configure do |cfg|
      cfg.login    = config['login']
      cfg.password = config['password']
      cfg.env      = Hypercharge::Env::Sandbox

      cfg.faraday do |f|
        # f.response :body_logger
      end

    end
  end
end