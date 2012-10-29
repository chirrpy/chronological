module Chronological
  module Base
    def base_timeframe(options = {})
      define_method(:in_progress?) do
        return false unless has_absolute_timeframe?

        (send(options[:starting_time]) <= Time.now.utc) && send(options[:ending_time]).future?
      end

      class_eval do
        alias active? in_progress?
      end
    end
  end
end
