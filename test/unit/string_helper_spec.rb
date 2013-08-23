require 'minitest_helper'

describe Hypercharge::StringHelpers do
  describe 'camelize' do
    it 'must camelize properly' do
      Hypercharge::StringHelpers.camelize('sale').must_equal 'Sale'
      Hypercharge::StringHelpers.camelize('init_recurring_sale').must_equal 'InitRecurringSale'
      Hypercharge::StringHelpers.camelize('referenced_fund_transfer').must_equal 'ReferencedFundTransfer'
      Hypercharge::StringHelpers.camelize('test').must_equal 'Test'
    end
  end

  describe 'underscore' do
    it 'must underscore camecase properly' do
      Hypercharge::StringHelpers.underscore('Sale').must_equal 'sale'
      Hypercharge::StringHelpers.underscore('InitRecurringSale').must_equal 'init_recurring_sale'
      Hypercharge::StringHelpers.underscore('ReferencedFundTransfer').must_equal 'referenced_fund_transfer'
      Hypercharge::StringHelpers.underscore('RGBColor').must_equal 'rgb_color'
      Hypercharge::StringHelpers.underscore('Test').must_equal 'test'
    end

    it 'must underscore uppercase properly' do
      Hypercharge::StringHelpers.underscore('APPROVED').must_equal 'approved'
    end

    it 'must underscore uppercase with _ properly' do
      Hypercharge::StringHelpers.underscore('IN_PROGRESS').must_equal 'in_progress'
    end

  end
end