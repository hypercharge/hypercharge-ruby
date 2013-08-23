# encoding: UTF-8
module Hypercharge
  class Scheduler
    enum :Type do
      include ::Hypercharge::Concerns::Enum::CamelizedName
      SchedulerCreate()
      SchedulerUpdate()
    end
  end
end