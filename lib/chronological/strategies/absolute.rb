module Chronological
  class AbsoluteStrategy
    def initialize(field_names = {})
      @field_names = field_names
    end

    def module
      Chronological::AbsoluteStrategy::MyModule
    end

    def field_names
      @field_names.dup
    end

    module MyModule
    module ClassMethods
      # TODO: Needs to be able to add a validation option which can do the
      # typical timeliness validation such as ended_at should be after started_at
      # and that both should validate timeliness
      def strategy_timeframe(options = {})
        define_method(:scheduled?) do
          optional_time_zone = !options[:time_zone].nil? ? send(options[:time_zone]) : true

          send(options[:starting_time]).present? && send(options[:ending_time]).present? && optional_time_zone
        end

        define_method(:partially_scheduled?) do
          optional_time_zone = !options[:time_zone].nil? ? send(options[:time_zone]) : false

          send(options[:starting_time]).present? || send(options[:ending_time]).present? || optional_time_zone
        end

        ###
        # Scopes
        #
        define_singleton_method(:by_date) do
          order "#{table_name}.#{options[:starting_time]} ASC, #{table_name}.#{options[:ending_time]} ASC"
        end

        define_singleton_method(:by_date_reversed) do
          order "#{table_name}.#{options[:starting_time]} DESC, #{table_name}.#{options[:ending_time]} DESC"
        end

        define_singleton_method(:expired) do
          where(arel_table[options[:ending_time]].lteq(Time.now.utc))
        end

        define_singleton_method(:current) do
          where(arel_table[options[:ending_time]].gt(Time.now.utc))
        end

        define_singleton_method(:in_progress) do
          started.current
        end

        define_singleton_method(:started) do
          where(arel_table[options[:starting_time]].lteq Time.now.utc)
        end

        define_singleton_method(:in_progress?) do
          in_progress.any?
        end

        ###
        # Aliases
        #
        # Aliasing date methods to make code more readable
        instance_eval do
          alias active? in_progress?
          alias active  in_progress
        end

        base_timeframe  start_date_field: options[:starting_date],
                        start_time_field: options[:starting_time],
                        end_date_field:   options[:ending_date],
                        end_time_field:   options[:ending_time]

      private
        define_method(:has_absolute_timeframe?) do
          send(options[:starting_time]).present? && send(options[:ending_time]).present?
        end

        define_method(:duration_in_seconds) do
          (send(options[:ending_time]) - send(options[:starting_time]))
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
