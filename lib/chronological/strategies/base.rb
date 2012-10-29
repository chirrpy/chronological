module Chronological
  class BaseStrategy
    def initialize(field_names = {})
      @field_names = field_names
    end

    def field_names
      @field_names.dup
    end

    def starting_date(object)
      return nil unless object.send(field_names[:starting_time]).respond_to? :to_date

      object.send(field_names[:starting_time]).to_date
    end

    def ending_date(object)
      return nil unless object.send(field_names[:ending_time]).respond_to? :to_date

      object.send(field_names[:ending_time]).to_date
    end
  end
end
