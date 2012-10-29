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

    def scheduled?(object)
      optional_time_zone = !field_names[:time_zone].nil? ? object.send(field_names[:time_zone]) : true

      object.send(field_names[:starting_time]).present? &&
      object.send(field_names[:ending_time]).present? &&
      optional_time_zone
    end

    def partially_scheduled?(object)
      optional_time_zone = !field_names[:time_zone].nil? ? object.send(field_names[:time_zone]) : false

      object.send(field_names[:starting_time]).present? ||
      object.send(field_names[:ending_time]).present? ||
      optional_time_zone
    end

    def self.by_date(object, field_names)
      object.order "#{object.table_name}.#{field_names[:starting_time]} ASC, #{object.table_name}.#{field_names[:ending_time]} ASC"
    end

    def self.by_date_reversed(object, field_names)
      object.order "#{object.table_name}.#{field_names[:starting_time]} DESC, #{object.table_name}.#{field_names[:ending_time]} DESC"
    end

    module ClassMethods
      # TODO: Needs to be able to add a validation option which can do the
      # typical timeliness validation such as ended_at should be after started_at
      # and that both should validate timeliness
      def strategy_timeframe(field_names = {})

        ###
        # Scopes
        #

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
