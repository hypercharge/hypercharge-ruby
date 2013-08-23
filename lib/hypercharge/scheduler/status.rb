# encoding: UTF-8

require 'renum'

module Hypercharge
  class Scheduler
    enum :Status do
      include ::Hypercharge::Concerns::Enum::UpcaseName
      RUNNING()
      EXPIRING()
    end
  end
end
