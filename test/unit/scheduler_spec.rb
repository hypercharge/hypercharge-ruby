require 'minitest_helper'

describe Hypercharge::Scheduler do

  describe 'the instance' do
    it 'gets created from response params' do
      s = Hypercharge::Scheduler.new(json_fixture('responses/scheduler'))
      s.unique_id.must_equal 'e1420438c52b4cb3a03a14a7e4fc16e1'
      s.payment_transaction_unique_id.must_equal 'e1420438c52b4cb3a03a14a7e4fc16e1'
      s.start_date.must_equal Date.parse('2013-11-13')
      s.end_date.must_equal Date.parse('2014-06-30')
      s.interval.must_equal Hypercharge::Scheduler::Interval::MONTHLY
      s.amount.must_equal 731_00
      s.currency.must_equal 'USD'
      s.active.must_equal true
      s.timestamp.must_equal Time.parse('2013-08-13T16:42:09Z')
      # s.expiring_notification_time.must_equal 30
    end
  end

  describe 'static methods' do
    it 'creates the notification' do
      notification = Hypercharge::Scheduler.notification({})
      notification.must_be_instance_of Hypercharge::SchedulerNotification
    end
  end

  describe 'Api calls' do
    it 'creates a scheduler' do
      stub_request(:post, /scheduler/) \
        .with(:body => json_fixture('requests/scheduler_create'),
          :headers => {"Content-Type" => "application/json"}) \
        .to_return(:body => json_fixture('responses/scheduler'),
          :headers => {"Content-Type" => "application/json"})


      s = Hypercharge::Scheduler.create(json_fixture('requests/scheduler_create'))
      s.must_be_instance_of Hypercharge::Scheduler
      s.unique_id.must_equal 'e1420438c52b4cb3a03a14a7e4fc16e1'
      s.amount.must_equal 731_00
      s.start_date.must_equal Date.parse('2013-11-13')
      s.end_date.must_equal Date.parse('2014-06-30')
      s.interval.must_equal Hypercharge::Scheduler::Interval::MONTHLY
      s.active.must_equal true

    end

    it 'gets a page of Schedulers with 3 results' do

      stub_request(:get, /scheduler/) \
        .with( #:query => json_fixture('requests/scheduler_index_get_params'),
          :headers => {"Content-Type" => "application/json"}) \
        .to_return(:body => json_fixture('responses/scheduler_page_1'),
          :headers => {"Content-Type" => "application/json"})


      params = {
        "page" => 1,
        "per_page" => 20,
        "start_date_from"=> "2014-03-01",
        "start_date_to"  => "2014-04-01",
        "end_date_from"  => "2015-09-01",
        "end_date_to"    => "2015-10-01",
        "active" => true
      }

      collection = Hypercharge::Scheduler.page(params)
      collection.must_be_instance_of Hypercharge::PaginatedCollection
      collection.page.must_equal 1
      collection.total_count.must_equal 10
      collection.pages_count.must_equal 2
      collection.per_page.must_equal 7
      collection.each do |rs|
        rs.must_be_instance_of Hypercharge::Scheduler
      end
    end

    it 'iterates over all Schedulers' do
      stub_request(:get, /scheduler/) \
        .with(:headers => {"Content-Type" => "application/json"}) \
        .to_return(:body => json_fixture('responses/scheduler_page_1'),
          :headers => {"Content-Type" => "application/json"}).then \
        .to_return(:body => json_fixture('responses/scheduler_page_2'),
          :headers => {"Content-Type" => "application/json"})

      count = 0
      Hypercharge::Scheduler.each() do |rs|
        rs.must_be_instance_of Hypercharge::Scheduler
        count += 1
      end
      count.must_equal 10
    end

    it 'finds a scheduler by unique_id' do
      stub_request(:get, /scheduler\/e1420438c52b4cb3a03a14a7e4fc16e1\.json/) \
        .with( :headers => {"Content-Type" => "application/json"}) \
        .to_return(:body => json_fixture('responses/scheduler'),
           :headers => {"Content-Type" => "application/json"})



      s = Hypercharge::Scheduler.find('e1420438c52b4cb3a03a14a7e4fc16e1')
      s.must_be_instance_of Hypercharge::Scheduler
      s.unique_id.must_equal 'e1420438c52b4cb3a03a14a7e4fc16e1'
      s.amount.must_equal 731_00
      s.start_date.must_equal Date.parse('2013-11-13')
      s.end_date.must_equal Date.parse('2014-06-30')
      s.interval.must_equal Hypercharge::Scheduler::Interval::MONTHLY
      s.active.must_equal true
    end


    it 'updates a scheduler' do
      params = json_fixture('requests/scheduler_create')
      params.delete 'payment_transaction_unique_id'
      stub_request(:put, /scheduler/) \
        .with(:body => params,
          :headers => {"Content-Type" => "application/json"}) \
        .to_return(:body => json_fixture('responses/scheduler'),
           :headers => {"Content-Type" => "application/json"})



      s = Hypercharge::Scheduler.update('e1420438c52b4cb3a03a14a7e4fc16e1', params)
      s.must_be_instance_of Hypercharge::Scheduler
      s.unique_id.must_equal 'e1420438c52b4cb3a03a14a7e4fc16e1'
      s.amount.must_equal 731_00
      s.start_date.must_equal Date.parse('2013-11-13')
      s.end_date.must_equal Date.parse('2014-06-30')
      s.interval.must_equal Hypercharge::Scheduler::Interval::MONTHLY
      s.active.must_equal true
    end

    it 'delete a Scheduler' do
      stub_request(:delete, /scheduler/) \
        .with( :headers => {"Content-Type" => "application/json"}) \
        .to_return(:headers => {"Content-Type" => "application/json"})

      s = Hypercharge::Scheduler.delete( 'e1420438c52b4cb3a03a14a7e4fc16e1' )
      s.must_be_instance_of Hypercharge::Scheduler
      s.unique_id.must_equal 'e1420438c52b4cb3a03a14a7e4fc16e1'

    end
  end
end