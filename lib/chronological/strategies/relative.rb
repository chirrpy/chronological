module Chronological
  class RelativeStrategy < BaseStrategy
    def module
      Chronological::RelativeStrategy::ClassMethods
    end

    def starting_time(object)
      return nil unless object.send(field_names[:base_of_offset]).present? && object.send(field_names[:starting_offset]).present?

      object.send(field_names[:base_of_offset]) - object.send(field_names[:starting_offset])
    end

    def ending_time(object)
      return nil unless object.send(field_names[:base_of_offset]).present? && object.send(field_names[:ending_offset]).present?

      object.send(field_names[:base_of_offset]) - object.send(field_names[:ending_offset])
    end

    def scheduled?(object)
      object.send(field_names[:base_of_offset]).present?  &&
      object.send(field_names[:starting_offset]).present? &&
      object.send(field_names[:ending_offset]).present? &&
      super
    end

    def partially_scheduled?(object)
      object.send(field_names[:base_of_offset]).present? ||
      object.send(field_names[:starting_offset]).present? ||
      object.send(field_names[:ending_offset]).present? ||
      super
    end

    def self.in_progress(object, field_names)
      object.all.select(&:in_progress?)
    end

    def self.in_progress?(object, field_names)
      object.all.any?(&:in_progress?)
    end

    def has_absolute_start?
      false
    end

    def has_absolute_end?
      false
    end

  private
    def duration_in_seconds(object)
      return nil unless object.send(field_names[:starting_offset]).present? && object.send(field_names[:ending_offset]).present?

      object.send(field_names[:starting_offset]) - object.send(field_names[:ending_offset])
    end

    def has_absolute_timeframe?(object)
      object.scheduled?
    end

    module ClassMethods
      def strategy_timeframe(field_names = {})
      end
    end
  end
end
