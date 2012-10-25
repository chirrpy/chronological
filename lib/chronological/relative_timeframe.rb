module Chronological
  module RelativeTimeframe
    module ClassMethods
      def relative_timeframe(options = {})
        base_time_field        = options[:base_utc] || options[:base]
        base_time_field_is_utc = options.has_key? :base_utc
        time_field_utc_suffix  = base_time_field_is_utc ? 'utc' : nil

        start_time_field       = ['started_at', time_field_utc_suffix].join('_')
        end_time_field         = ['ended_at',   time_field_utc_suffix].join('_')
        start_date_field       = ['started_on', time_field_utc_suffix].join('_')
        end_date_field         = ['ended_on',   time_field_utc_suffix].join('_')

        define_method(start_time_field) do
          return nil unless send(base_time_field).present? && send(options[:start]).present?

          send(base_time_field) - send(options[:start])
        end

        define_method(end_time_field) do
          return nil unless send(base_time_field).present? && send(options[:end]).present?

          send(base_time_field) - send(options[:end])
        end

        define_method(:in_progress?) do
          return false unless scheduled?

          send(start_time_field) <= Time.now && Time.now < send(end_time_field)
        end

        define_method(:scheduled?) do
          send(base_time_field).present? && send(options[:start]).present? && send(options[:end]).present?
        end

        define_method(:partially_scheduled?) do
          send(base_time_field).present? || send(options[:start]).present? || send(options[:end]).present?
        end

        class_eval do
          alias active? in_progress?
        end

        base_timeframe  start_date_field: start_date_field,
                        start_time_field: start_time_field,
                        end_date_field:   end_date_field,
                        end_time_field:   end_time_field

      private
        define_method(:duration_in_seconds) do
          return nil unless send(options[:start]).present? && send(options[:end]).present?

          send(options[:start]) - send(options[:end])
        end
      end
    end

    def self.included(base)
      base.extend Chronological::Base
      base.extend ClassMethods
    end
  end
end
