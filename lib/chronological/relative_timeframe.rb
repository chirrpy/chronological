module Chronological
  module RelativeTimeframe
    module ClassMethods
      def relative_timeframe(options = {})
        define_method(:in_progress?) do
          return false unless base_time.present? && starting_offset.present? && ending_offset.present?

          start_time = send(options[:base]) - send(options[:start])
          end_time   = send(options[:base]) - send(options[:end])

          start_time <= Time.now && Time.now < end_time
        end

        class_eval do
          alias active? in_progress?
        end
      end
    end

    def self.included(base)
      base.extend ClassMethods
    end
  end
end
