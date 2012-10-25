module Chronological
  module AbsoluteTimeframe
    module ClassMethods
      # TODO: Needs to be able to add a validation option which can do the
      # typical timeliness validation such as ended_at should be after started_at
      # and that both should validate timeliness
      def absolute_timeframe(options = {})
        start_time_field            = options[:start_utc] || options[:start]
        start_date_field            = start_time_field.to_s.gsub(/_at/, '_on')
        end_time_field              = options[:end_utc]   || options[:end]
        end_date_field              = end_time_field.to_s.gsub(/_at/, '_on')
        time_zone                   = options[:time_zone]
        start_time_field_is_utc     = options.has_key? :start_utc
        end_time_field_is_utc       = options.has_key? :end_utc
        start_time_field_utc_suffix = start_time_field_is_utc ? '_utc' : ''
        end_time_field_utc_suffix   = end_time_field_is_utc ? '_utc' : ''

        define_method(:in_progress?) do
          return false unless has_absolute_timeframe?

          (send(start_time_field) <= Time.now.utc) && send(end_time_field).future?
        end

        define_method(:scheduled?) do
          optional_time_zone = !options[:time_zone].nil? ? send(time_zone) : true

          send(start_time_field).present? && send(end_time_field).present? && optional_time_zone
        end

        define_method(:partially_scheduled?) do
          optional_time_zone = !options[:time_zone].nil? ? send(time_zone) : false

          send(start_time_field).present? || send(end_time_field).present? || optional_time_zone
        end

        ###
        # Scopes
        #
        self.class.send(:define_method, :by_date) do
          order "#{table_name}.#{start_time_field} ASC, #{table_name}.#{end_time_field} ASC"
        end

        self.class.send(:define_method, :by_date_reversed) do
          order "#{table_name}.#{start_time_field} DESC, #{table_name}.#{end_time_field} DESC"
        end

        self.class.send(:define_method, :expired) do
          where("#{end_time_field} <= :now", :now => Time.now.utc)
        end

        self.class.send(:define_method, :current) do
          where("#{end_time_field} > :now", :now => Time.now.utc)
        end

        self.class.send(:define_method, :in_progress) do
          where("#{start_time_field} <= :now AND #{end_time_field} > :now", :now => Time.now.utc)
        end

        self.class.send(:define_method, :started) do
          where("#{start_time_field} <= :now", :now => Time.now.utc)
        end

        self.class.send(:define_method, :in_progress?) do
          in_progress.any?
        end

        instance_eval do
          alias active? in_progress?
          alias active  in_progress
        end

        ###
        # Aliases
        #
        # Aliasing date methods to make code more readable
        class_eval do
          alias_attribute   :"starts_at#{start_time_field_utc_suffix}",    start_time_field.to_sym
          alias_attribute   :"starting_at#{start_time_field_utc_suffix}",  start_time_field.to_sym
          alias_attribute   :"ends_at#{start_time_field_utc_suffix}",      end_time_field.to_sym
          alias_attribute   :"ending_at#{start_time_field_utc_suffix}",    end_time_field.to_sym
        end

        base_timeframe  start_date_field: start_date_field,
                        start_time_field: start_time_field,
                        end_date_field:   end_date_field,
                        end_time_field:   end_time_field

      private
        define_method(:has_absolute_timeframe?) do
          send(start_time_field).present? && send(end_time_field).present?
        end

        define_method(:duration_in_seconds) do
          (send(end_time_field) - send(start_time_field))
        end
      end
    end

    def self.included(base)
      base.extend Chronological::Base
      base.extend ClassMethods
    end
  end
end
