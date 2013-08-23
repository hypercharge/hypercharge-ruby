# encoding: UTF-8

require 'hypercharge/paginated_collection'

module Hypercharge
  module ApiCalls
    # this module contians all API call related to the Scheduler
    # within the Hypercharge gateway.
    module Scheduler

      # create a scheduler in a previously successful init_recurring_* transaction
      # @param [Hash] data
      # @return [Scheduler] scheduler
      def create(data)
        request(:post, 'scheduler.json', data, ::Hypercharge::Scheduler::Type::SchedulerCreate)
      end

      # gets a Scheduler
      # @param [String] unique_id unique_id f the scheduler
      # @return [Scheduler] scheduler
      def find(unique_id)
        request(:get, "scheduler/#{unique_id}.json")
      end


      # updates a scheduler
      # @param [Hash] data
      # @return [Scheduler] scheduler
      def update(unique_id, data)
        request(:put, "scheduler/#{unique_id}.json", data, ::Hypercharge::Scheduler::Type::SchedulerUpdate)
      end

      # get a page of schedulers
      # @param  [Hash] options  options hash allow to specify `:page`, `:per_page`... see schema
      # @return [Scheduler] scheduler
      def page(options = {})
        # default to page 1
        options[:page] ||= 1

        # make the request manually -> do not try to create Scheduler
        url = Hypercharge.config.env.payment_transaction_base_uri.join('v2/scheduler.json')
        response_hash = Hypercharge::HTTPS.request(:get, url, options)

        # support for deprecated current_page
        page = response_hash['page'] || response_hash['current_page']


        PaginatedCollection.create(page, response_hash['per_page'], response_hash['total_entries']) do |c|
          c.concat response_hash['entries'].map{ |h| Hypercharge::Scheduler.new( h ) }
        end
      end

      # iterares over all schedulers
      # @param [Hash] options  options hash allow to specify `:start_date` and `:end_date`...see schema
      # @yield [Scheduler] scheduler
      def each(options = {})
        begin
          collection = page(options)
          collection.each do |item|
            yield item
          end
          options[:page] = collection.next_page
        end while collection.next_page?
      end

      # deletes a Scheduler
      # @param [String] unique_id the unique_id of the scheduler
      # @return [Scheduler] scheduler
      def delete(unique_id)
        url = Hypercharge.config.env.payment_transaction_base_uri.join('v2/').join("scheduler/#{unique_id}.json")

        response_hash = Hypercharge::HTTPS.request(:delete, url, nil)

        ::Hypercharge::Scheduler.new('unique_id' => unique_id)
      end



    private

      def request(http_method, path, data = {}, schema = nil)
        url = Hypercharge.config.env.payment_transaction_base_uri.join('v2/').join(path)

        response_hash = Hypercharge::HTTPS.request(http_method, url, data, schema)

        ::Hypercharge::Scheduler.new(response_hash)
      end

    end
  end
end
