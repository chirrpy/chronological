module Chronological
  class AbsoluteStrategy < BaseStrategy
    def scheduled?(object)
      object.send(field_names[:starting_time]).present? &&
      object.send(field_names[:ending_time]).present? &&
      super
    end

    def partially_scheduled?(object)
      object.send(field_names[:starting_time]).present? ||
      object.send(field_names[:ending_time]).present? ||
      super
    end

    def has_absolute_start?
      true
    end

    def has_absolute_end?
      true
    end

    def self.by_date(object, field_names, direction)
      object.order "#{object.table_name}.#{field_names[:starting_time]} #{direction}, #{object.table_name}.#{field_names[:ending_time]} #{direction}"
    end

    def self.ended(object, field_names)
      object.where object.arel_table[field_names[:ending_time]].lteq(Time.now.utc)
    end

    def self.not_yet_ended(object, field_names)
      object.where object.arel_table[field_names[:ending_time]].gt(Time.now.utc)
    end

    def self.in_progress(object, field_names)
      object.started.not_yet_ended
    end

    def self.in_progress?(object, field_names)
      object.in_progress.any?
    end

    def self.started(object, field_names)
      object.where object.arel_table[field_names[:starting_time]].lteq(Time.now.utc)
    end

  private
    def duration_in_seconds(object)
      (object.send(field_names[:ending_time]) - object.send(field_names[:starting_time]))
    end

    def has_absolute_timeframe?(object)
      object.send(field_names[:starting_time]).present? && object.send(field_names[:ending_time]).present?
    end
  end
end
