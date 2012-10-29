module Chronological
  class RelativeStrategy < BaseStrategy
    def module
      Chronological::RelativeStrategy::ClassMethods
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
        class_eval do
          columns_hash[field_names[:starting_time]] = ActiveRecord::ConnectionAdapters::Column.new(field_names[:starting_time], nil, 'datetime')
          columns_hash[field_names[:ending_time]]   = ActiveRecord::ConnectionAdapters::Column.new(field_names[:ending_time],   nil, 'datetime')
        end

        define_method(field_names[:starting_time]) do
          return nil unless send(field_names[:base_of_offset]).present? && send(field_names[:starting_offset]).present?

          send(field_names[:base_of_offset]) - send(field_names[:starting_offset])
        end

        define_method(field_names[:ending_time]) do
          return nil unless send(field_names[:base_of_offset]).present? && send(field_names[:ending_offset]).present?

          send(field_names[:base_of_offset]) - send(field_names[:ending_offset])
        end
      end
    end
  end
end
