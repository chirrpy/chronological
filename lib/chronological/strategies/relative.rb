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

    module ClassMethods
      def strategy_timeframe(options = {})
        class_eval do
          columns_hash[options[:starting_time]] = ActiveRecord::ConnectionAdapters::Column.new(options[:starting_time], nil, 'datetime')
          columns_hash[options[:ending_time]]   = ActiveRecord::ConnectionAdapters::Column.new(options[:ending_time],   nil, 'datetime')
        end

        define_method(options[:starting_time]) do
          return nil unless send(options[:base_of_offset]).present? && send(options[:starting_offset]).present?

          send(options[:base_of_offset]) - send(options[:starting_offset])
        end

        define_method(options[:ending_time]) do
          return nil unless send(options[:base_of_offset]).present? && send(options[:ending_offset]).present?

          send(options[:base_of_offset]) - send(options[:ending_offset])
        end

        define_method(:scheduled?) do
          send(options[:base_of_offset]).present? && send(options[:starting_offset]).present? && send(options[:ending_offset]).present?
        end

        define_method(:partially_scheduled?) do
          send(options[:base_of_offset]).present? || send(options[:starting_offset]).present? || send(options[:ending_offset]).present?
        end

        ###
        # Scopes
        #
        define_singleton_method(:in_progress) do
          all.select(&:in_progress?)
        end

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
          return nil unless send(options[:starting_offset]).present? && send(options[:ending_offset]).present?

          send(options[:starting_offset]) - send(options[:ending_offset])
        end
      end
    end
  end
end
