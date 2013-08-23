require 'minitest_helper'

require 'hypercharge/hash_util'

describe Hypercharge::HashUtil do

  describe "defaults!" do
    it 'stringifies keys and applies defaults' do
      hash = {:a => {:b => {:c => 'the c value'}}}
      hash = Hypercharge::HashUtil.defaults!(hash, {'a.b.c' => 'a new value'})
      hash.must_equal({'a' => {'b' => {'c' => 'a new value'}}})
    end
  end

  describe 'apply_defaults' do
    describe 'with key_path' do
      it 'must apply fixed value' do
        hash = {'a' => {'b' =>  {'c' => { 'd' => {'e' => 'the e value'}}}}}
        hash = Hypercharge::HashUtil.apply_defaults(hash, {'a.b' => 'B'})
        hash.must_equal({'a' => {'b' => 'B'}})
      end

      it 'must apply defaults with lamda' do
        hash = {'a' => {'b' =>  {'c' => { 'd' => {'e' => 'the e value'}}}}}
        hash = Hypercharge::HashUtil.apply_defaults(hash, {'a.b' => lambda{|b_value| 'B from lambda'} })
        hash.must_equal({'a' => {'b' => 'B from lambda'}})
      end

      it 'must add nested value' do
        hash = {'a' => {'b' => 'b'}}
        hash = Hypercharge::HashUtil.apply_defaults(hash, {'a.x' => 'X' })
        hash.must_equal({'a' => {'b' => 'b', 'x' => 'X'}})
      end

      it 'wont add value to root' do
        hash = {'a' => 'A'}
        hash = Hypercharge::HashUtil.apply_defaults(hash, {'.x' => 'X' })
        hash.must_equal({'a' => 'A'})
      end
    end

    describe 'with key' do
      it 'must apply defaults with fixed value' do
        hash = {'a' => {'b' =>  {'c' => { 'd' => {'e' => 'the e value'}}}}}
        hash = Hypercharge::HashUtil.apply_defaults(hash, {'b' => 'B'})
        hash.must_equal({'a' => {'b' => 'B'}})
      end

      it 'must apply defaults with lamda' do
        hash = {'a' => {'b' =>  {'c' => { 'd' => {'e' => 'the e value'}}}}}
        hash = Hypercharge::HashUtil.apply_defaults(hash, {'b' => lambda{|b_value| 'B from lambda'} })
        hash.must_equal({'a' => {'b' => 'B from lambda'}})
      end

      it 'wont add nested value' do
        hash = {'a' => {'b' => 'b'}}
        hash = Hypercharge::HashUtil.apply_defaults(hash, {'x' => 'X' })
        hash.must_equal({'a' => {'b' => 'b'}})
      end

      it 'wont add root value' do
        hash = {'a' => 'A'}
        hash = Hypercharge::HashUtil.apply_defaults(hash, {'x' => 'X' })
        hash.must_equal({'a' => 'A'})
      end
    end

  end

  describe 'fetch_path' do
    it 'must fetch path of string key' do
      hash = {'a' => {'b' =>  {'c' => { 'd' => {'e' => 'the e value'}}}}}
      res = Hypercharge::HashUtil.fetch_path(hash, %w(a b c d))
      res.must_equal({'e' => 'the e value'})
    end

    it 'wont fetch non existing path' do
      hash = {'a' => {'b' =>  {'c' => { 'd' => {'e' => 'the e value'}}}}}
      res = Hypercharge::HashUtil.fetch_path(hash, %w(f z))
      res.must_equal(nil)
    end
  end

  describe 'fetch_parent_of_key' do
    it 'must fetch parent of symbol key' do
      hash = {:a => {:b =>  {:c => { :d => {:e => 'the e value'}}}}}
      res = Hypercharge::HashUtil.fetch_parent_of_key(hash, :e)
      res.must_equal({:e => 'the e value'})
    end

    it 'must fetch parent of string key' do
      hash = {:a => {'b' =>  {:c => { :d => {'e' => 'the e value'}}}}}
      res = Hypercharge::HashUtil.fetch_parent_of_key(hash, 'e')
      res.must_equal({'e' => 'the e value'})
    end

    it 'wont fetch non existing key' do
      hash = {:a => {'b' =>  {:c => { :d => {'e' => 'the e value'}}}}}
      res = Hypercharge::HashUtil.fetch_parent_of_key(hash, 'z')
      res.must_equal(nil)
    end

  end

  describe 'stringify_keys' do
    it 'must stringify symbols keys' do
      hash = {:a => {:b => {:c => 'the c value'}}}
      hash = Hypercharge::HashUtil.defaults!(hash, {})
      hash.must_equal({'a' => {'b' => {'c' => 'the c value'}}})
    end

    it 'must be able to handle string keys' do
      hash = {'a' => {'b' => {'c' => 'the c value'}}}
      hash = Hypercharge::HashUtil.defaults!(hash, {})
      hash.must_equal({'a' => {'b' => {'c' => 'the c value'}}})
    end
  end
end

