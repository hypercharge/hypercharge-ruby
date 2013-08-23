require 'minitest_helper'

describe Hypercharge::Payment::Status  do

  it 'must create from lowercase name' do
    Hypercharge::Payment::Status.with_name('approved').must_equal Hypercharge::Payment::Status::APPROVED
    Hypercharge::Payment::Status.with_name('error').must_equal Hypercharge::Payment::Status::ERROR
  end

  it 'must create from uppercase name' do
    Hypercharge::Payment::Status.with_name('APPROVED').must_equal Hypercharge::Payment::Status::APPROVED
    Hypercharge::Payment::Status.with_name('ERROR').must_equal Hypercharge::Payment::Status::ERROR
  end

  it 'must return name' do
    Hypercharge::Payment::Status::APPROVED.name.must_equal 'APPROVED'
    Hypercharge::Payment::Status::ERROR.name.must_equal 'ERROR'
  end

  it 'must return hc_name' do
    Hypercharge::Payment::Status::APPROVED.hc_name.must_equal 'approved'
    Hypercharge::Payment::Status::ERROR.hc_name.must_equal 'error'
  end

  it 'must respond to inquiry method' do
    s = Hypercharge::Payment::Status::APPROVED
    s.approved?.must_equal true
    s.error?.must_equal false

    s = Hypercharge::Payment::Status::DECLINED
    s.declined?.must_equal true
    s.error?.must_equal false
  end

end