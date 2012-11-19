require 'chronological/version'
require 'chronological/errors'
require 'chronological/strategy_resolver'
require 'chronological/strategies'

module Chronological
  def timeframe(*args)
    options  = args.first.is_a?(Hash) ? args.pop : {}
    strategy = Chronological::StrategyResolver.resolve(options)

    class_eval do
      columns_hash[strategy.field_names[:starting_time].to_s] ||= ActiveRecord::ConnectionAdapters::Column.new(strategy.field_names[:starting_time], nil, 'datetime')
      columns_hash[strategy.field_names[:ending_time].to_s]   ||= ActiveRecord::ConnectionAdapters::Column.new(strategy.field_names[:ending_time],   nil, 'datetime')
      columns_hash[strategy.field_names[:starting_date].to_s] ||= ActiveRecord::ConnectionAdapters::Column.new(strategy.field_names[:starting_date], nil, 'date')
      columns_hash[strategy.field_names[:ending_date].to_s]   ||= ActiveRecord::ConnectionAdapters::Column.new(strategy.field_names[:ending_date],   nil, 'date')
    end

    # TODO: Once we implement anonymous modules in Greenwich and Chronological, then
    # we can call `super` here which would call Greenwich which would convert the
    # time over to UTC.
    if strategy.has_absolute_start?
      define_method(strategy.field_names[:starting_time]) do |*args|
        super().try(:utc)
      end
    else
      define_method(strategy.field_names[:starting_time]) do |*args|
        options = args.last.is_a?(Hash) ? args.last : {}

        strategy.starting_time(self, options)
      end
    end

    # TODO: Once we implement anonymous modules in Greenwich and Chronological, then
    # we can call `super` here which would call Greenwich which would convert the
    # time over to UTC.
    if strategy.has_absolute_end?
      define_method(strategy.field_names[:ending_time]) do |*args|
        super().try(:utc)
      end
    else
      define_method(strategy.field_names[:ending_time]) do |*args|
        options = args.last.is_a?(Hash) ? args.last : {}

        strategy.ending_time(self, options)
      end
    end

    define_method(:started?) do |*args|
      options = args.last.is_a?(Hash) ? args.last : {}

      strategy.started?(self, options)
    end

    define_method(:ended?) do |*args|
      options = args.last.is_a?(Hash) ? args.last : {}

      strategy.ended?(self, options)
    end

    define_method(:not_yet_ended?) do |*args|
      options = args.last.is_a?(Hash) ? args.last : {}

      strategy.not_yet_ended?(self, options)
    end

    define_method(:scheduled?) do
      strategy.scheduled?(self)
    end

    define_method(:partially_scheduled?) do
      strategy.partially_scheduled?(self)
    end

    define_method(:inactive?) do
      strategy.inactive?(self)
    end

    define_method(:in_progress?) do
      strategy.in_progress?(self)
    end

    define_method(:duration) do |options|
      strategy.duration(self, options)
    end

    define_method(strategy.field_names[:starting_date]) do
      strategy.starting_date(self)
    end

    define_method(strategy.field_names[:ending_date]) do
      strategy.ending_date(self)
    end

    ###
    # Scopes
    #
    define_singleton_method(:by_date) do |direction = :asc|
      strategy.class.by_date(self, strategy.field_names, direction)
    end

    define_singleton_method(:ended) do
      strategy.class.ended(self, strategy.field_names)
    end

    define_singleton_method(:not_yet_ended) do
      strategy.class.not_yet_ended(self, strategy.field_names)
    end

    define_singleton_method(:in_progress) do
      strategy.class.in_progress(self, strategy.field_names)
    end

    define_singleton_method(:started) do
      strategy.class.started(self, strategy.field_names)
    end

    define_singleton_method(:in_progress?) do
      strategy.class.in_progress?(self, strategy.field_names)
    end

    ###
    # Aliases
    #
    instance_eval do
      alias active? in_progress?
      alias active  in_progress
    end

    class_eval do
      alias active? in_progress?
    end
  end
end
