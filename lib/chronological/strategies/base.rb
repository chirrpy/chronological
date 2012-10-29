module Chronological
  class BaseStrategy
    def initialize(field_names = {})
      @field_names = field_names
    end

    def field_names
      @field_names.dup
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

    def duration(object)
      calculated_duration = duration_in_seconds(object)

      return Hash.new unless calculated_duration.present?

      hours   = (calculated_duration / 3600).to_i
      minutes = ((calculated_duration % 3600) / 60).to_i
      seconds = (calculated_duration % 60).to_i

      { :hours => hours, :minutes => minutes, :seconds => seconds }
    end

    def scheduled?(object)
      !field_names[:time_zone].nil? ? object.send(field_names[:time_zone]) : true
    end

    def partially_scheduled?(object)
      !field_names[:time_zone].nil? ? object.send(field_names[:time_zone]) : false
    end

    def in_progress?(object)
      return false unless has_absolute_timeframe?(object)

      (object.send(field_names[:starting_time]) <= Time.now.utc) && object.send(field_names[:ending_time]).future?
    end

    ###
    # Scopes
    #
    def self.started(object, field_names)
      object.where "#{started_at_sql_calculation(field_names)} <= :as_of", :as_of => Time.now.utc
    end

    def self.ended(object, field_names)
      object.where "#{ended_at_sql_calculation(field_names)} <= :as_of", :as_of => Time.now.utc
    end

    def self.not_yet_ended(object, field_names)
      object.where "#{ended_at_sql_calculation(field_names)} > :as_of", :as_of => Time.now.utc
    end

    def self.in_progress(object, field_names)
      object.started.not_yet_ended
    end

    def self.in_progress?(object, field_names)
      object.in_progress.any?
    end

    def self.by_date(object, field_names, direction)
      object.order "#{object.table_name}.#{started_at_sql_calculation(field_names)} #{direction}, #{object.table_name}.#{ended_at_sql_calculation(field_names)} #{direction}"
    end

    def self.by_duration(object, field_names, direction)
      object.order "#{duration_sql_calculation(field_names)} #{direction}"
    end
  end
end
