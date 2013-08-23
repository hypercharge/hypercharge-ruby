# encoding: UTF-8

module Hypercharge

  class PaginatedCollection < Array
    attr_accessor :per_page, :page, :total_count, :pages_count

    def self.create(page, per_page, total_count)
      new.tap do |c|
        c.page        = page.to_i
        c.per_page    = per_page.to_i
        c.total_count = total_count.to_i
        c.pages_count = (total_count.to_f / per_page.to_f).ceil
        yield c if block_given?
      end
    end

    def entries
      self
    end

    def next_page?
      page < pages_count
    end

    def next_page
      page + 1 if next_page?
    end
  end
end