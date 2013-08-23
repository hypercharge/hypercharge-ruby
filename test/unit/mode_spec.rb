require 'minitest_helper'

describe Hypercharge::Mode do

  it 'must create from lowercase name' do
    Hypercharge::Mode.with_name('test').must_equal Hypercharge::Mode::TEST
    Hypercharge::Mode.with_name('live').must_equal Hypercharge::Mode::LIVE
  end

  it 'must create from uppercase name' do
    Hypercharge::Mode.with_name('TEST').must_equal Hypercharge::Mode::TEST
    Hypercharge::Mode.with_name('LIVE').must_equal Hypercharge::Mode::LIVE
  end

  it 'must return name' do
    Hypercharge::Mode::TEST.name.must_equal 'TEST'
    Hypercharge::Mode::LIVE.name.must_equal 'LIVE'
  end

  it 'must return hc_name' do
    Hypercharge::Mode::TEST.hc_name.must_equal 'test'
    Hypercharge::Mode::LIVE.hc_name.must_equal 'live'
  end

end