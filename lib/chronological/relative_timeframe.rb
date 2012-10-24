module Chronological
  module RelativeTimeframe
    module ClassMethods
      def relative_timeframe(*args)
      end
    end

    def self.included(base)
      base.extend ClassMethods
    end
  end
end
