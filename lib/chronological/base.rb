module Chronological
  module Base
    def base_timeframe(options = {})
      define_method(:inactive?) do
        !active?
      end

      define_method(:duration) do
        return Hash.new unless duration_in_seconds.present?

        hours   = (duration_in_seconds / 3600).to_i
        minutes = ((duration_in_seconds % 3600) / 60).to_i
        seconds = (duration_in_seconds % 60).to_i

        { :hours => hours, :minutes => minutes, :seconds => seconds }
      end

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
