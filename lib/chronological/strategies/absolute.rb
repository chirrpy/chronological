module Chronological
  class AbsoluteStrategy < BaseStrategy
    def scheduled?(object)
      object.send(field_names[:starting_time]).present? &&
      object.send(field_names[:ending_time]).present? &&
      scheduled_time_zone(object, true).present?
    end

    def partially_scheduled?(object)
      object.send(field_names[:starting_time]).present? ||
      object.send(field_names[:ending_time]).present? ||
      scheduled_time_zone(object, false).present?
    end

    def has_absolute_start?
      true
    end

    def has_absolute_end?
      true
    end

  private
    def self.started_at_sql(field_names)
      field_names[:starting_time]
    end

    def self.ended_at_sql(field_names)
      field_names[:ending_time]
    end

    def self.duration_sql(field_names)
      "extract ('epoch' from (#{field_names[:ending_time]} - #{field_names[:starting_time]}))"
    end

    def duration_in_seconds(object)
      (object.send(field_names[:ending_time]) - object.send(field_names[:starting_time]))
    end

    def has_absolute_timeframe?(object)
      object.send(field_names[:starting_time]).present? && object.send(field_names[:ending_time]).present?
    end
  end
end
