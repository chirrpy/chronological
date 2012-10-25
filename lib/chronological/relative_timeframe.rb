module Chronological
  module RelativeTimeframe
    module ClassMethods
      def relative_timeframe(options = {})
        define_method(:in_progress?) do
          return false unless scheduled?

          start_time = send(options[:base]) - send(options[:start])
          end_time   = send(options[:base]) - send(options[:end])

          start_time <= Time.now && Time.now < end_time
        end

        define_method(:scheduled?) do
          send(options[:base]).present? && send(options[:start]).present? && send(options[:end]).present?
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
