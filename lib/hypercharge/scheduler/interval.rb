# encoding: UTF-8

require 'renum'

module Hypercharge
  class Scheduler
    enum :Interval do
      include ::Hypercharge::Concerns::Enum::UpcaseName
      DAILY()
      WEEKLY()
      MONTHLY()
      ANUALLY()
    end
  end
end
