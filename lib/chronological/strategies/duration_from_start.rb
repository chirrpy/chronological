module Chronological
  class DurationFromStartStrategy < BaseStrategy
    def ending_time(object, options = {})
      return nil unless object.send(field_names[:starting_time]).present? &&
                        object.send(field_names[:duration]).present?

      object.send(field_names[:starting_time]) +
      object.send(field_names[:duration])
    end

    def scheduled?(object)
      object.send(field_names[:starting_time]).present? &&
      object.send(field_names[:duration]).present?      &&
      scheduled_time_zone(object, true).present?
    end

    def partially_scheduled?(object)
      object.send(field_names[:starting_time]).present? ||
      object.send(field_names[:duration]).present?      ||
      scheduled_time_zone(object, false).present?
    end

    def self.in_progress(object, field_names)
      object.all.select(&:in_progress?)
    end

    def self.in_progress?(object, field_names)
      object.all.any?(&:in_progress?)
    end

    def has_absolute_start?
      true
    end

    def has_absolute_end?
      false
    end

  private
    def self.started_at_sql(field_names)
      field_names[:starting_time]
    end

    def self.ended_at_sql(field_names)
      "#{field_names[:starting_time]} + (#{field_names[:duration]} * INTERVAL '1 seconds')"
    end

    def self.duration_sql(field_names)
      field_names[:duration]
    end

    def duration_in_seconds(object)
      return nil unless object.send(field_names[:duration]).present?

      object.send(field_names[:duration])
    end

    def has_absolute_timeframe?(object)
      object.scheduled?
    end
  end
end
