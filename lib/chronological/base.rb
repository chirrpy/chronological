module Chronological
  module Base
    def base_timeframe(options = {})
      define_method(options[:start_date_field]) do
        return nil unless send(options[:start_time_field]).respond_to? :to_date

        send(options[:start_time_field]).to_date
      end

      define_method(options[:end_date_field]) do
        return nil unless send(options[:end_time_field]).respond_to? :to_date

        send(options[:end_time_field]).to_date
      end

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

        (send(options[:start_time_field]) <= Time.now.utc) && send(options[:end_time_field]).future?
      end

      class_eval do
        alias active? in_progress?
      end
    end
  end
end