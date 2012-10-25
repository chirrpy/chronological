module Chronological
  module RelativeTimeframe
    module ClassMethods
      def relative_timeframe(options = {})
        define_method(:in_progress?) do
          base_time       = send(options[:base])
          starting_offset = send(options[:start])
          ending_offset   = send(options[:end])

          return false unless base_time.present? && starting_offset.present? && ending_offset.present?

          start_time = base_time - starting_offset
          end_time   = base_time - ending_offset

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
