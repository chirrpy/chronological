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

    def inactive?(object)
      !object.in_progress?
    end

    def duration(object)
      calculated_duration = duration_in_seconds(object)

      return Hash.new unless calculated_duration.present?

      hours   = (calculated_duration / 3600).to_i
      minutes = ((calculated_duration % 3600) / 60).to_i
      seconds = (calculated_duration % 60).to_i

      { :hours => hours, :minutes => minutes, :seconds => seconds }
    end
  end
end
