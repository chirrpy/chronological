module Chronological
  class RelativeStrategy
    def initialize(field_names = {})
      @field_names = field_names
    end

    def module
      Chronological::RelativeStrategy::ClassMethods
    end

    def field_names
      @field_names.dup
    end

    def scheduled?(object)
      object.send(field_names[:base_of_offset]).present?  &&
      object.send(field_names[:starting_offset]).present? &&
      object.send(field_names[:ending_offset]).present?
    end

    def partially_scheduled?(object)
      object.send(field_names[:base_of_offset]).present? ||
      object.send(field_names[:starting_offset]).present? ||
      object.send(field_names[:ending_offset]).present?
    end

    def self.in_progress(object, field_names)
      object.all.select(&:in_progress?)
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

        ###
        # Scopes
        #
        define_singleton_method(:in_progress?) do
          all.any?(&:in_progress?)
        end

        ###
        # Aliases
        #
        # Aliasing date methods to make code more readable
        instance_eval do
          alias active? in_progress?
          alias active  in_progress
        end

      private
        define_method(:has_absolute_timeframe?) do
          scheduled?
        end

        define_method(:duration_in_seconds) do
          return nil unless send(field_names[:starting_offset]).present? && send(field_names[:ending_offset]).present?

          send(field_names[:starting_offset]) - send(field_names[:ending_offset])
        end
      end
    end
  end
end
