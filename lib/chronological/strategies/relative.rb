module Chronological
  class RelativeStrategy
    def module
      Chronological::RelativeStrategy::MyModule
    end

    def initialize(*args)
    end

    module MyModule
    module ClassMethods
      def strategy_timeframe(options = {})
        base_time_field        = options[:base_utc] || options[:base]
        start_time_field       = :started_at
        end_time_field         = :ended_at
        start_date_field       = :started_on
        end_date_field         = :ended_on

        class_eval do
          columns_hash[start_time_field] = ActiveRecord::ConnectionAdapters::Column.new(start_time_field, nil, 'datetime')
          columns_hash[end_time_field]   = ActiveRecord::ConnectionAdapters::Column.new(end_time_field,   nil, 'datetime')
        end

        define_method(start_time_field) do
          return nil unless send(base_time_field).present? && send(options[:start]).present?

          send(base_time_field) - send(options[:start])
        end

        define_method(end_time_field) do
          return nil unless send(base_time_field).present? && send(options[:end]).present?

          send(base_time_field) - send(options[:end])
        end

        define_method(:scheduled?) do
          send(base_time_field).present? && send(options[:start]).present? && send(options[:end]).present?
        end

        define_method(:partially_scheduled?) do
          send(base_time_field).present? || send(options[:start]).present? || send(options[:end]).present?
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

        base_timeframe  start_date_field: start_date_field,
                        start_time_field: start_time_field,
                        end_date_field:   end_date_field,
                        end_time_field:   end_time_field

      private
        define_method(:has_absolute_timeframe?) do
          scheduled?
        end

        define_method(:duration_in_seconds) do
          return nil unless send(options[:start]).present? && send(options[:end]).present?

          send(options[:start]) - send(options[:end])
        end
      end
    end

    def self.included(base)
      base.extend Chronological::Base
      base.extend ClassMethods
    end
    end
  end
end
