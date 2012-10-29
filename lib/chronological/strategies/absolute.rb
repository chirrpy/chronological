module Chronological
  class AbsoluteStrategy
    def initialize(field_names = {})
      @field_names = field_names
    end

    def module
      Chronological::AbsoluteStrategy::ClassMethods
    end

    def field_names
      @field_names.dup
    end

    module ClassMethods
      # TODO: Needs to be able to add a validation option which can do the
      # typical timeliness validation such as ended_at should be after started_at
      # and that both should validate timeliness
      def strategy_timeframe(field_names = {})
        define_method(:scheduled?) do
          optional_time_zone = !field_names[:time_zone].nil? ? send(field_names[:time_zone]) : true

          send(field_names[:starting_time]).present? && send(field_names[:ending_time]).present? && optional_time_zone
        end

        define_method(:partially_scheduled?) do
          optional_time_zone = !field_names[:time_zone].nil? ? send(field_names[:time_zone]) : false

          send(field_names[:starting_time]).present? || send(field_names[:ending_time]).present? || optional_time_zone
        end

        ###
        # Scopes
        #
        define_singleton_method(:by_date) do
          order "#{table_name}.#{field_names[:starting_time]} ASC, #{table_name}.#{field_names[:ending_time]} ASC"
        end

        define_singleton_method(:by_date_reversed) do
          order "#{table_name}.#{field_names[:starting_time]} DESC, #{table_name}.#{field_names[:ending_time]} DESC"
        end

        define_singleton_method(:expired) do
          where(arel_table[field_names[:ending_time]].lteq(Time.now.utc))
        end

        define_singleton_method(:current) do
          where(arel_table[field_names[:ending_time]].gt(Time.now.utc))
        end

        define_singleton_method(:in_progress) do
          started.current
        end

        define_singleton_method(:started) do
          where(arel_table[field_names[:starting_time]].lteq Time.now.utc)
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

      private
        define_method(:has_absolute_timeframe?) do
          send(field_names[:starting_time]).present? && send(field_names[:ending_time]).present?
        end

        define_method(:duration_in_seconds) do
          (send(field_names[:ending_time]) - send(field_names[:starting_time]))
        end
      end
    end
  end
end
