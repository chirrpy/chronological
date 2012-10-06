module Chronological
  module ClassMethods
    ###
    # Scopes
    #
    def by_date
      order "#{table_name}.started_at_utc ASC, #{table_name}.ended_at_utc ASC"
    end

    def by_date_reversed
      order "#{table_name}.started_at_utc DESC, #{table_name}.ended_at_utc DESC"
    end

    def expired
      where('ended_at_utc < :now', :now => Time.now.utc)
    end

    def current
      where('ended_at_utc > :now', :now => Time.now.utc)
    end

    def in_progress
      where('started_at_utc <= :now AND ended_at_utc > :now', :now => Time.now.utc)
    end

    alias active in_progress

    def in_progress?
      in_progress.any?
    end

    alias active? in_progress?

    def started
      where("started_at_utc <= :now", :now => Time.now.utc)
    end
  end

  def self.included(base)
    base.extend ClassMethods
  end

  ###
  # Aliases
  #
  # Aliasing date methods to make code more readable

  alias_attribute  :starts_at,        :started_at
  alias_attribute  :starting_at,      :started_at
  alias_attribute  :ends_at,          :ended_at
  alias_attribute  :ending_at,        :ended_at
  alias_attribute  :starts_at_utc,    :started_at_utc
  alias_attribute  :starting_at_utc,  :started_at_utc
  alias_attribute  :ends_at_utc,      :ended_at_utc
  alias_attribute  :ending_at_utc,    :ended_at_utc

  def started_at_utc_date
    return nil unless started_at_utc.respond_to? :to_date

    started_at_utc.to_date
  end

  def ended_at_utc_date
    return nil unless ended_at_utc.respond_to? :to_date

    ended_at_utc.to_date
  end

  def in_progress?
    return false unless scheduled?

    (started_at_utc <= Time.now.utc) && ended_at_utc.future?
  end

  alias active? in_progress?

  def inactive?
    !active?
  end

  def scheduled?
    started_at_utc.present? && ended_at_utc.present?
  end

  def partially_scheduled?
    started_at_utc.present? || ended_at_utc.present?
  end

  def duration
    hours   = (duration_in_minutes / 60).to_int
    minutes = (duration_in_minutes % 60).to_int

    { :hours => hours, :minutes => minutes }
  end

private
  def duration_in_minutes
    @duration_in_minutes ||= (ended_at_utc - started_at_utc) / 60
  end
end
