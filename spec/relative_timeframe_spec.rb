require 'spec_helper'

class Chronologicable < ActiveRecord::Base
  include Chronological::RelativeTimeframe

  relative_timeframe :start => :starting_offset,
                     :end   => :ending_offset,
                     :base  => :started_at_utc
end

describe Chronological::RelativeTimeframe, :timecop => true do
end
