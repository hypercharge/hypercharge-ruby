# encoding: UTF-8

require "renum"

module Hypercharge
  # this represents the mode of a Payment or Transaction
  # NOTE: only Live means that real money was involved
  enum :Mode do
    include Concerns::Enum::UpcaseName
    TEST()
    LIVE()
  end
end