require 'minitest_helper'
require 'renum'

class A
  enum :Status do
    include Hypercharge::Concerns::Enum::UpcaseName
    ENABLED()
    DISABLED()
    IN_PROGRESS()
  end
end

class B
  enum :Status do
    include Hypercharge::Concerns::Enum::CamelizedName
    Enabled()
    Disabled()
    InProgress()
  end
end

class C
  enum :Status do
    include Hypercharge::Concerns::Enum::Inquirer
    ENABLED()
    DISABLED()
    InProgress()
  end
end

describe Hypercharge::Concerns::Enum do

  describe 'UpcaseName' do
    it 'must be accessible with lowercase name' do
      A::Status.with_name('enabled').must_equal A::Status::ENABLED
      A::Status.with_name('disabled').must_equal A::Status::DISABLED
    end

    it 'must be accessible with uppcase name' do
      A::Status.with_name('ENABLED').must_equal A::Status::ENABLED
      A::Status.with_name('DISABLED').must_equal A::Status::DISABLED
    end

    it 'must return hc_name' do
      A::Status::ENABLED.hc_name.must_equal 'enabled'
      A::Status::DISABLED.hc_name.must_equal 'disabled'
    end
  end

  describe 'CamelizedName' do
    it 'must be accessible with underscrore name' do
      B::Status.with_name('enabled').must_equal B::Status::Enabled
      B::Status.with_name('disabled').must_equal B::Status::Disabled
      B::Status.with_name('in_progress').must_equal B::Status::InProgress
    end

    it 'must be accessible with camecase name' do
      B::Status.with_name('Enabled').must_equal B::Status::Enabled
      B::Status.with_name('Disabled').must_equal B::Status::Disabled
      B::Status.with_name('InProgress').must_equal B::Status::InProgress
    end

    it 'must return hc_name' do
      B::Status::Enabled.hc_name.must_equal 'enabled'
      B::Status::Disabled.hc_name.must_equal 'disabled'
      B::Status::InProgress.hc_name.must_equal 'in_progress'
    end
  end

  describe 'Inquirer' do
    it 'must detect the uppcase instance' do
      s = C::Status::ENABLED
      s.enabled?.must_equal true
      s.ENABLED?.must_equal true

      s.disbaled?.must_equal false
      s.DISABLED?.must_equal false

      s.abc?.must_equal false
    end

    it 'must detect the camelcase instance' do
      s = C::Status::InProgress
      s.in_progress?.must_equal true
      s.InProgress?.must_equal true

      s.disbaled?.must_equal false
      s.DISABLED?.must_equal false

      s.abc?.must_equal false
    end
  end
end