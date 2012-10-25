module Chronological
  module Base
    def base_timeframe(options = {})
      define_method(options[:start_date_field]) do
        return nil unless send(options[:start_time_field]).respond_to? :to_time

        send(options[:start_time_field]).to_date
      end

      define_method(options[:end_date_field]) do
        return nil unless send(options[:end_time_field]).respond_to? :to_time

        send(options[:end_time_field]).to_date
      end
    end
  end
end
