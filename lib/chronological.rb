module Chronological
  module ClassMethods
    def chronological(options = {})
      start_field            = options[:start_utc] || options[:start]
      end_field              = options[:end_utc]   || options[:end]
      time_zone              = options[:time_zone]
      start_field_is_utc     = options.has_key? :start_utc
      end_field_is_utc       = options.has_key? :end_utc
      start_field_utc_suffix = start_field_is_utc ? '_utc' : ''
      end_field_utc_suffix   = end_field_is_utc ? '_utc' : ''

      define_method(:started_at_utc_date) do
        return nil unless send(start_field).respond_to? :to_date

        send(start_field).to_date
      end

      define_method(:ended_at_utc_date) do
        return nil unless send(end_field).respond_to? :to_date

        send(end_field).to_date
      end

      define_method(:in_progress?) do
        return false unless scheduled?

        (send(start_field) <= Time.now.utc) && send(end_field).future?
      end

      define_method(:inactive?) do
        !active?
      end

      define_method(:scheduled?) do
        optional_time_zone = !options[:time_zone].nil? ? send(time_zone) : true

        send(start_field).present? && send(end_field).present? && optional_time_zone
      end

      define_method(:partially_scheduled?) do
        optional_time_zone = !options[:time_zone].nil? ? send(time_zone) : false

        send(start_field).present? || send(end_field).present? || optional_time_zone
      end

      define_method(:duration) do
        hours   = (duration_in_seconds / 3600).to_i
        minutes = ((duration_in_seconds % 3600) / 60).to_i
        seconds = (duration_in_seconds % 60).to_i

        { :hours => hours, :minutes => minutes, :seconds => seconds }
      end

      ###
      # Scopes
      #
      self.class.send(:define_method, :by_date) do
        order "#{table_name}.#{start_field} ASC, #{table_name}.#{end_field} ASC"
      end

      self.class.send(:define_method, :by_date_reversed) do
        order "#{table_name}.#{start_field} DESC, #{table_name}.#{end_field} DESC"
      end

      self.class.send(:define_method, :expired) do
        where("#{end_field} <= :now", :now => Time.now.utc)
      end

      self.class.send(:define_method, :current) do
        where("#{end_field} > :now", :now => Time.now.utc)
      end

      self.class.send(:define_method, :in_progress) do
        where("#{start_field} <= :now AND #{end_field} > :now", :now => Time.now.utc)
      end

      self.class.send(:define_method, :started) do
        where("#{start_field} <= :now", :now => Time.now.utc)
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
        alias_attribute   :"starts_at#{start_field_utc_suffix}",    start_field.to_sym
        alias_attribute   :"starting_at#{start_field_utc_suffix}",  start_field.to_sym
        alias_attribute   :"ends_at#{start_field_utc_suffix}",      end_field.to_sym
        alias_attribute   :"ending_at#{start_field_utc_suffix}",    end_field.to_sym

        alias             active?                                   in_progress?
      end

    private
      define_method(:duration_in_seconds) do
        (send(end_field) - send(start_field))
      end
    end
  end

  def self.included(base)
    base.extend ClassMethods
  end
end
