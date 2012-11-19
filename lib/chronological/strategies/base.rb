module Chronological
  class BaseStrategy
    attr_reader :field_names

    def initialize(field_names = {})
      @field_names = field_names.freeze
    end

    def starting_date(object)
      return nil unless object.send(field_names[:starting_time]).respond_to? :to_date

      object.send(field_names[:starting_time]).to_date
    end

    def ending_date(object)
      return nil unless object.send(field_names[:ending_time]).respond_to? :to_date

      object.send(field_names[:ending_time]).to_date
    end

    def inactive?(object)
      !object.in_progress?
    end

    def duration(object, options = { :in => [:days, :hours, :minutes, :seconds] })
      duration_parts      = options[:in]
      remaining_duration  = duration_in_seconds(object)

      return Hash.new unless remaining_duration.present?

      if duration_parts.include? :days
        days                = remaining_duration / 86400
        remaining_duration  = remaining_duration % 86400
      end

      if duration_parts.include? :hours
        hours               = remaining_duration / 3600
        remaining_duration  = remaining_duration % 3600
      end

      if duration_parts.include? :minutes
        minutes             = remaining_duration / 60
        remaining_duration  = remaining_duration % 60
      end

      if duration_parts.include? :seconds
        seconds             = remaining_duration
      end

      { :days => days, :hours => hours, :minutes => minutes, :seconds => seconds }.select {|k,v| !v.nil?}
    end

    def in_progress?(object)
      return false unless has_absolute_timeframe?(object)

      (object.send(field_names[:starting_time]) <= Time.now.utc) && object.send(field_names[:ending_time]).future?
    end

    def started?(object, options = {})
      Time.now >= object.send(field_names[:starting_time], options)
    end

    def ended?(object, options = {})
      Time.now >= object.send(field_names[:ending_time], options)
    end

    def not_yet_ended?(object, options = {})
      !ended?(object, options)
    end

    ###
    # Scopes
    #
    def self.started(object, field_names)
      object.where "#{started_at_sql(field_names)} <= :as_of", :as_of => Time.now.utc
    end

    def self.ended(object, field_names)
      object.where "#{ended_at_sql(field_names)} <= :as_of", :as_of => Time.now.utc
    end

    def self.not_yet_ended(object, field_names)
      object.where "#{ended_at_sql(field_names)} > :as_of", :as_of => Time.now.utc
    end

    def self.in_progress(object, field_names)
      object.started.not_yet_ended
    end

    def self.in_progress?(object, field_names)
      object.in_progress.any?
    end

    def self.by_date(object, field_names, direction)
      object.order "#{object.table_name}.#{started_at_sql(field_names)} #{direction}, #{object.table_name}.#{ended_at_sql(field_names)} #{direction}"
    end

    def self.by_duration(object, field_names, direction)
      object.order "#{duration_sql(field_names)} #{direction}"
    end

  private
    def scheduled_time_zone(object, default)
      !field_names[:time_zone].nil? ? object.send(field_names[:time_zone]) : default
    end
  end
end
