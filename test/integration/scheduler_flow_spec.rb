require 'minitest_integration_helper'
require 'mechanize'

describe 'SchedulerFlow' do
  it 'finds a Scheduler' do
    params =   json_fixture("requests/init_recurring_sale_with_recurring_schedule").values.first
    params['expiration_year'] = "#{Time.now.year + 2}"
    params['recurring_schedule']['start_date'] = "#{Time.now.year + 1}-01-01"

    a = Hypercharge::Transaction.init_recurring_sale(channel_token,  params)

    a.transaction_type.must_equal Hypercharge::Transaction::Type::InitRecurringSale
    a.status.must_equal Hypercharge::Transaction::Status::APPROVED

    rs = a.recurring_scheduler
    rs.must_be_instance_of Hypercharge::Scheduler
    rs.unique_id.must_match /[a-f0-9]{32}/
    rs.start_date.must_equal Date.parse("#{Time.now.year + 1}-01-01")
    rs.amount.must_equal 50_00
    rs.interval.must_equal Hypercharge::Scheduler::Interval::MONTHLY
    rs.active.must_equal true
    rs.enabled.must_equal true

    rs = Hypercharge::Scheduler.find(rs.unique_id )
    rs.must_be_instance_of Hypercharge::Scheduler
    rs.unique_id.must_match /[a-f0-9]{32}/
    rs.start_date.must_equal Date.parse("#{Time.now.year + 1}-01-01")
    rs.amount.must_equal 50_00
    rs.interval.must_equal Hypercharge::Scheduler::Interval::MONTHLY
    rs.active.must_equal true
  end

  it 'creates a scheduler' do
    sale_params =   json_fixture("requests/init_recurring_sale_with_recurring_schedule").values.first
    sale_params['expiration_year'] = "#{Time.now.year + 2}"
    sale_params.delete('recurring_schedule')
    sale = Hypercharge::Transaction.init_recurring_sale(channel_token,  sale_params)

    scheduler_params = json_fixture('requests/scheduler_create')
    scheduler_params['payment_transaction_unique_id'] = sale.unique_id
    scheduler_params['start_date'] = "#{Time.now.year + 1}-01-01"
    scheduler_params['end_date'] = "#{Time.now.year + 2}-01-01"
    scheduler_params['amount'] = sale_params['amount']



    rs = Hypercharge::Scheduler.create(scheduler_params)
    rs.must_be_instance_of Hypercharge::Scheduler
    rs.unique_id.must_match /[a-f0-9]{32}/
    rs.payment_transaction_unique_id.must_equal sale.unique_id
    rs.start_date.must_equal Date.parse("#{Time.now.year + 1}-01-01")
    rs.end_date.must_equal Date.parse("#{Time.now.year + 2}-01-01")
    rs.amount.must_equal 50_00
    rs.interval.must_equal Hypercharge::Scheduler::Interval::MONTHLY
    rs.active.must_equal true
  end

  it 'gets a paginated list of schedulers' do
    collection = Hypercharge::Scheduler.page
    collection.must_be_instance_of Hypercharge::PaginatedCollection
    collection.page.must_equal 1
    collection.per_page.must_equal 50

    s = collection.first
    s.must_be_instance_of Hypercharge::Scheduler
  end

  it 'iterares over all schedulers' do
    Hypercharge::Scheduler.each do |scheduler|
        scheduler.must_be_instance_of Hypercharge::Scheduler
        break
    end
  end

  it 'updates a scheduler' do
    sale_params =   json_fixture("requests/init_recurring_sale_with_recurring_schedule").values.first
    sale_params['expiration_year'] = "#{Time.now.year + 2}"
    sale_params.delete('recurring_schedule')
    sale = Hypercharge::Transaction.init_recurring_sale(channel_token,  sale_params)

    scheduler_params = json_fixture('requests/scheduler_create')
    scheduler_params['payment_transaction_unique_id'] = sale.unique_id
    scheduler_params['start_date'] = "#{Time.now.year + 1}-01-01"
    scheduler_params['end_date'] = "#{Time.now.year + 2}-01-01"
    scheduler_params['amount'] = sale_params['amount']



    rs = Hypercharge::Scheduler.create(scheduler_params)
    rs.must_be_instance_of Hypercharge::Scheduler
    rs.interval.must_equal Hypercharge::Scheduler::Interval::MONTHLY
    rs.active.must_equal true

    rs = Hypercharge::Scheduler.update(rs.unique_id, :interval => 'weekly')
    rs.must_be_instance_of Hypercharge::Scheduler
    rs.interval.must_equal Hypercharge::Scheduler::Interval::WEEKLY

    rs = Hypercharge::Scheduler.update(rs.unique_id, :active => false)
    rs.must_be_instance_of Hypercharge::Scheduler
    rs.active.must_equal false
  end

  it 'deletes a scheduler' do
    sale_params =   json_fixture("requests/init_recurring_sale_with_recurring_schedule").values.first
    sale_params['expiration_year'] = "#{Time.now.year + 2}"
    sale_params.delete('recurring_schedule')
    sale = Hypercharge::Transaction.init_recurring_sale(channel_token,  sale_params)

    scheduler_params = json_fixture('requests/scheduler_create')
    scheduler_params['payment_transaction_unique_id'] = sale.unique_id
    scheduler_params['start_date'] = "#{Time.now.year + 1}-01-01"
    scheduler_params['end_date'] = "#{Time.now.year + 2}-01-01"
    scheduler_params['amount'] = sale_params['amount']

    rs = Hypercharge::Scheduler.create(scheduler_params)
    rs.must_be_instance_of Hypercharge::Scheduler

    rs = Hypercharge::Scheduler.delete(rs.unique_id)
    rs.must_be_instance_of Hypercharge::Scheduler

  end
end