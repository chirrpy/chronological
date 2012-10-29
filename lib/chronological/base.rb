module Chronological
  module Base
    def base_timeframe(options = {})
      class_eval do
        alias active? in_progress?
      end
    end
  end
end
